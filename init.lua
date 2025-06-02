local core_mainmenu = require("core_mainmenu")
local lib_keys = require("solylib.keys")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")
local lib_menu = require("solylib.menu")
local Notification = require("psobb-action-notificator.notification")
local Notificator = require("psobb-action-notificator.notificator")

local enableAddon = true

local function Color(r, g, b, a)
    if a == nil then
        a = 1.0
    end
    return { r = r, g = g, b = b, a = a }
end

local function getNeedShiftaMessage()
    local messages = {}
    local playerList = lib_characters.GetPlayerList()
    for i = 1, #playerList, 1 do
        local address = playerList[i].address
        local atkTech = lib_characters.GetPlayerTechniqueStatus(address, 0)
        if atkTech.type == 0 then
            table.insert(messages, lib_characters.GetPlayerName(address) .. " NEEDS SHIFTA!")
        end
        if 0 < atkTech.time and atkTech.time <= 30 then
            local msg = string.format("SHIFTA expires in %i sec: %s",
                atkTech.time,
                lib_characters.GetPlayerName(address))
            table.insert(messages, msg)
        end
    end
    return messages
end

local function presentNeedShifta()
    local msgs = getNeedShiftaMessage()
    for _, msg in ipairs(msgs) do
        Notificator.add(Notification:new(msg, Color(1.0, 0.0, 0.0)))
    end
end

local function isHumarClass(class)
    return (
        class == 0 or -- Humar
        class == 1 or -- Hunewerl
        class == 2 or -- Hucast
        class == 9 -- Hucaseal
    )
end

local function presentDFReady()
    local _PlayerArray = 0x00A94254
    local _PlayerIndex = 0x00A9C4F4
    local playerIndex = pso.read_u32(_PlayerIndex)
    local playerAddr = pso.read_u32(_PlayerArray + 4 * playerIndex)

    if playerAddr == 0 then return nil end

    local class = lib_characters.GetPlayerClass(playerAddr)
    if not isHumarClass(class) then return nil end

    local hp = lib_characters.GetPlayerHP(playerAddr)
    local mhp = lib_characters.GetPlayerMaxHP(playerAddr)
    if 0 < hp and (hp / mhp) < 0.125 then
        Notificator.add(Notification:new("DF Ready!", Color(1.0, 1.0, 0.0)))
    end
end

local function presentInv()
    local address = lib_characters.GetSelf()
    local invuln = lib_characters.GetPlayerInvulnerabilityStatus(address)
    if invuln.time > 0 then
        local str = string.format("Inv: %s", os.date("!%M:%S", invuln.time))
        Notificator.add(Notification:new(str, Color(0.0, 1.0, 0.0)))
    end
end

local function isInLobby()
    local _Location = 0x00AAFC9C
    local location = pso.read_u32(_Location + 0x04)
    return location == 15
end

local function shouldBeDisplay()
    if lib_characters.GetCurrentFloorSelf() == 0 then
        return false
    end
    if lib_menu.IsMenuUnavailable() then
        return false
    end
    if isInLobby() then
        return false
    end
    return true
end

local function present()
    if enableAddon == false then
        return
    end

    Notificator.start()

    if shouldBeDisplay() ~= false then
        presentDFReady()
        presentNeedShifta()
        presentInv()
    end

    -- notificator.add(Notification:new("Need Deband", Color(0.0, 0.4, 1.0)))

    Notificator.notify()
end

local function keyPressed(key)
    -- control key
    if key == 17 then
        enableAddon = not enableAddon
    end
end

local function init()
    local function mainMenuButtonHandler()
        if enableAddon == false then
        end
        -- enableAddon = not enableAddon
    end

    core_mainmenu.add_button("Action Notificator", mainMenuButtonHandler)

    return
    {
        name = "Action Notificator",
        version = "0.0.1",
        author = "teapot",
        description = "For you who forget the shifta",
        present = present,
        key_pressed = keyPressed,
    }
end

return
{
    __addon =
    {
        init = init
    }
}
