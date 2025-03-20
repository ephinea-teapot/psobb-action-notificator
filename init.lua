local core_mainmenu = require("core_mainmenu")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")
local lib_menu = require("solylib.menu")

local enableAddon = true

local function displayDFReady()
    local windowParams = { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" }
    local text = "DF Ready!"
    local width, height = imgui.CalcTextSize(text)

    local scale = 1.5
    local windowWidth = width * scale + 20
    local windowHeight = height * scale + 20
    local ps = lib_helpers.GetPosBySizeAndAnchor(0, 0, windowWidth, -200, 5)

    imgui.SetNextWindowSize(windowWidth, windowHeight, "Always")
    imgui.SetNextWindowPos(ps[1], ps[2], "Always")
    imgui.Begin(text, nil, windowParams)
    imgui.SetWindowFontScale(scale)
    imgui.TextColored(1.0, 1.0, 0.0, 1.0, text)
    imgui.End()
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
            displayDFReady()
        end
    end
end

local function shouldBeDisplay()
    if lib_menu.IsSymbolChatOpen() then
        return true
    end
    if lib_menu.IsMenuOpen() then
        return true
    end
    if lib_menu.IsMenuUnavailable() then
        return false
    end
    if lib_characters.GetCurrentFloorSelf() == 0 then
        return false
    end
    return true
end

local function present()
    if enableAddon == false then
        return
    end

    if shouldBeDisplay() ~= false then
        presentDFReady()
    end
end

local function init()
    local function mainMenuButtonHandler()
        if enableAddon == false then
        end
        enableAddon = not enableAddon
    end

    core_mainmenu.add_button("DF Ready", mainMenuButtonHandler)

    return
    {
        name = "DF Ready",
        version = "0.0.1",
        author = "teapot",
        description = "This is an add-on that tells you when Dark Flow's EX is ready to use.",
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
