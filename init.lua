local core_mainmenu = require("core_mainmenu")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")

local enableAddon = true

local function displayDFReady()
    local windowParams = { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" }
    local ps = lib_helpers.GetPosBySizeAndAnchor(0, 0, 100, -200, 5)
    imgui.SetNextWindowPos(ps[1], ps[2], "Always")
    imgui.Begin("DF Ready!", nil, windowParams)
    imgui.TextColored(1.0, 1.0, 0.0, 1.0, "DF Ready!")
    imgui.End()
end

local function presentDFReady()
    local address = lib_characters.GetPlayer(0)
    if address ~= 0 then
        local hp = lib_characters.GetPlayerHP(address)
        local mhp = lib_characters.GetPlayerMaxHP(address)
        if (hp / mhp) < 0.125 then
            displayDFReady()
        end
    end
end

local function present()
    if enableAddon == false then
        return
    end

    presentDFReady()
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
