local canvas = require("hs.canvas")
local window = require("hs.window")
local eventtap = require("hs.eventtap")

local M = {}
local monitored = {}
local keytap = nil

local keyDownType = eventtap.event.types.keyDown
local keyUpType = eventtap.event.types.keyUp
local flagsChangedType = eventtap.event.types.flagsChanged

function M.monitorKey(key, label, config)
    local x, y, w, h = config.x, config.y, config.w, config.h
    local textSize = config.textSize or 14
    local textColor = config.textColor or {red = 1, green = 1, blue = 1, alpha = 1}
    local upColor = config.upColor or {red = 0, green = 0.5, blue = 1, alpha = 0.5}
    local downColor = config.downColor or {red = 0, green = 0, blue = 1, alpha = 0.75}

    M.unmonitorKey(key)
    monitored[key] = {
        key = key,
        label = label,
        x = x,
        y = y,
        w = w,
        h = h,
        textSize = textSize,
        textColor = textColor,
        upColor = upColor,
        downColor = downColor
    }
end

function M.unmonitorKey(key)
    if monitored[key] ~= nil and monitored[key].canvas ~= nil then
        monitored[key].canvas:hide()
    end
    monitored[key] = nil
end

function M.start()
    M.stop()
    keytap = eventtap.new({keyDownType, keyUpType, flagsChangedType}, onKeyEvent)
    keytap:start()
end

function M.stop()
    if keytap ~= nil then
        keytap:stop()
        keytap = nil
        for _,v in pairs(monitored) do
            if v.upCanvas ~= nil then
                v.upCanvas:hide()
                v.upCanvas = nil
            end
            if v.downCanvas ~= nil then
                v.downCanvas:hide()
                v.downCanvas = nil
            end
        end
    end
end

function M.toggle()
    if keytap == nil then
        M.start()
    else
        M.stop()
    end
end

function M.snapToWindow(w, x, y)
    if keytap == nil then return end

    local frame = w:frame()
    x = frame.x + x * frame.w
    y = frame.y + y * frame.h
    
    for _,v in pairs(monitored) do
        if v.upCanvas ~= nil then v.upCanvas:hide() end
        if v.downCanvas ~= nil then v.downCanvas:hide() end
        v.upCanvas = createCanvas(v.x + x, v.y + y, v.w, v.h, v.label, v.textSize, v.textColor, v.upColor)
        v.downCanvas = createCanvas(v.x + x, v.y + y, v.w, v.h, v.label, v.textSize, v.textColor, v.downColor)
        v.upCanvas:show()
        v.downCanvas:hide()
    end
end

function onKeyEvent(e)
    local type = e:getType(true)
    if type == flagsChangedType then
        local flags = e:getFlags()
        updateCanvases("shift", flags.shift or false)
        updateCanvases("alt", flags.alt or false)
        updateCanvases("ctrl", flags.ctrl or false)
        updateCanvases("cmd", flags.cmd or false)
        updateCanvases("fn", flags.fn or false)
        return
    end
    
    local key = e:getKeyCode()
    if type == keyDownType then
        updateCanvases(key, true)
    elseif type == keyUpType then
        updateCanvases(key, false)
    end
end

function updateCanvases(key, down)
    if monitored[key] == nil then return end
    if down then
        if monitored[key].downCanvas ~= nil then monitored[key].downCanvas:show() end
        if monitored[key].upCanvas ~= nil then monitored[key].upCanvas:hide() end
    else
        if monitored[key].downCanvas ~= nil then monitored[key].downCanvas:hide() end
        if monitored[key].upCanvas ~= nil then monitored[key].upCanvas:show() end
    end
end

function createCanvas(x, y, w, h, label, textSize, textColor, backgroundColor)
    return canvas.new{x=x,y=y,w=w,h=h}:appendElements(
    {
        action = "build",
        padding = 0,
        type = "rectangle"
    },
    {
        action = "fill",
        fillColor = backgroundColor,
        frame = {x="0", y="0", w="1", h="1"},
        type = "rectangle"
    },
    {
        action = "fill",
        type = "text",
        text = label,
        textAlignment = "center",
        textColor = textColor,
        textSize = textSize
    })
end

return M