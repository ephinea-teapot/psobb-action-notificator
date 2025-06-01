Notification = {}
Notification.__index = Notification
function Notification:new(text, color)
    local obj = setmetatable({}, self)
    obj.text = text
    obj.color = color
    return obj
end

return Notification
