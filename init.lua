local core_mainmenu = require("core_mainmenu")
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
    local playerList = lib_characters.GetPlayerList()
    if #playerList == 1 then
        return nil
    end
    for i = 1, #playerList, 1 do
        local address = playerList[i].address
        local atkTech = lib_characters.GetPlayerTechniqueStatus(address, 0)
        if atkTech.type == 0 then
            return "Need Shifta!"
        end
        if atkTech.time <= 30 then
            return string.format("Shifta expires at %d sec", atkTech.time)
        end
    end
    return nil
end

local function presentNeedShifta()
    local msg = getNeedShiftaMessage()
    if msg == nil then return nil end
    Notificator.add(Notification:new(msg, Color(1.0, 0.0, 0.0)))
end

local function presentDFReady()
    local _PlayerArray = 0x00A94254
    local _PlayerIndex = 0x00A9C4F4
    local playerIndex = pso.read_u32(_PlayerIndex)
    local playerAddr = pso.read_u32(_PlayerArray + 4 * playerIndex)

    if playerAddr ~= 0 then
        local hp = lib_characters.GetPlayerHP(playerAddr)
        local mhp = lib_characters.GetPlayerMaxHP(playerAddr)
        if 0 < hp and (hp / mhp) < 0.125 then
            Notificator.add(Notification:new("DF Ready!", Color(1.0, 1.0, 0.0)))
        end
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
        -- key_pressed = key_pressed,
    }
end

return
{
    __addon =
    {
        init = init
    }
}
