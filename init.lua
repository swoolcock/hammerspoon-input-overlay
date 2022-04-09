local overlay = require("inputoverlay")
local window = require("hs.window")

overlay.monitorKey("shift", "grab", {x=-400,y=-40,w=40,h=40})
overlay.monitorKey(hs.keycodes.map["w"], "^", {x=-280-5,y=-80-5,w=40,h=40})
overlay.monitorKey(hs.keycodes.map["a"], "<", {x=-320-10,y=-40,w=40,h=40})
overlay.monitorKey(hs.keycodes.map["s"], "v", {x=-280-5,y=-40,w=40,h=40})
overlay.monitorKey(hs.keycodes.map["d"], ">", {x=-240,y=-40,w=40,h=40})

overlay.monitorKey(hs.keycodes.map["j"], "dash", {x=-160-15,y=-40,w=40,h=40})
overlay.monitorKey(hs.keycodes.map["k"], "jump", {x=-120-10,y=-40,w=40,h=40})
overlay.monitorKey(hs.keycodes.map["l"], "demo", {x=-80-5,y=-40,w=40,h=40})
overlay.monitorKey(hs.keycodes.map[";"], "jump", {x=-40,y=-40,w=40,h=40})

local function snap()
    overlay.snapToWindow(window.focusedWindow(), 1, 1)
end

local function toggle()
    overlay.toggle()
    snap()
end

hs.hotkey.bind({}, "f18", toggle)
hs.hotkey.bind({}, "f19", snap)
