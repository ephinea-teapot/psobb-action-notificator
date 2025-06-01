local windowParams = { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" }
local fontScale = 4

local function GetResolutionWidth()
    return pso.read_u32(pso.read_u32(0x82D140))
end

local function GetResolutionHeight()
    return pso.read_u32(pso.read_u32(0x82D18A))
end

local function layoutPositions(notifications, centerX, centerY)
    local _, itemHeight = imgui.CalcTextSize("A")
    itemHeight = itemHeight * fontScale
    local gap = itemHeight / 2
    local totalHeight = #notifications * itemHeight + (#notifications - 1) * gap
    local startY = centerY - totalHeight / 2
    local positions = {}
    for i, notification in ipairs(notifications) do
        local w, _ = imgui.CalcTextSize(notification.text)
        local x = centerX - (w * fontScale) / 2
        local y = startY + (i - 1) * (itemHeight + gap)
        table.insert(positions, { x = x, y = y })
    end
    return positions
end

local notifications = {}
local lastNotifications = nil
local lastPositions = {}

local function start()
    notifications = {}
end

local function add(notification)
    table.insert(notifications, notification)
end

local lastCalcedTextSize = nil

local function needUpdatePositions()
    if lastCalcedTextSize == nil then
        return true
    end

    local w = imgui.CalcTextSize("a")
    if lastCalcedTextSize ~= w then
        lastCalcedTextSize = w
        return true
    end
    lastCalcedTextSize = w

    if lastNotifications == nil then
        return true
    end
    if #lastNotifications ~= #notifications then
        return true
    end
    if lastPositions == nil then
        return true
    end
    return false
end

local function notify()
    if #notifications == 0 then
        return
    end

    local displayWidth = GetResolutionWidth()
    local displayHeight = GetResolutionHeight()
    local centerX = displayWidth / 2
    local centerY = displayHeight / 2

    local positions
    if needUpdatePositions() then
        positions = layoutPositions(notifications, centerX, centerY)
    else
        positions = lastPositions
    end

    for i, pos in ipairs(positions) do
        local x = pos.x
        local y = pos.y

        local notification = notifications[i]
        local color = notification.color
        local text = notification.text
        local width, height = imgui.CalcTextSize(text)
        local windowWidth = width * fontScale + 20
        local windowHeight = height * fontScale + 20

        imgui.SetNextWindowSize(windowWidth, windowHeight, "Always")
        imgui.SetNextWindowPos(x, y, "Always")
        imgui.Begin(text, nil, windowParams)
        imgui.SetWindowFontScale(fontScale)
        imgui.TextColored(color.r, color.g, color.b, color.a, text)
        imgui.End()
    end

    lastNotifications = notifications
    lastPositions = positions
end

return {
    start = start,
    add = add,
    notify = notify,
}
