--[[ 
Jason's hammerspoon hotkeys

change log:
  2023-03-20 - initial creation with R=reload, W=notify, Q=alert, C=clock
  2023-03-22 - added T=Teams linkinator
--]] 
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Q", function()
  hs.alert.show("Hello World!")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", function()
-- to do:
-- * detect whether there's a URL in the pasteboard
-- * detect app in focus and change output accordingly
  mypasteboard = hs.pasteboard.getContents()
  _, _, url, tag = string.find(mypasteboard, "(.*)/(.*)")
  hs.eventtap.keyStroke({"cmd"}, "k")
  hs.eventtap.keyStrokes(tag)
  -- hs.timer.usleep(20000)
  hs.eventtap.keyStroke({}, "tab")
  hs.eventtap.keyStrokes(mypasteboard)
  hs.eventtap.keyStroke({}, "return")
end)

hs.loadSpoon("AClock")
spoon.AClock:init() hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
  spoon.AClock:toggleShow()
end)

-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
-- 
--   f.x = f.x - 10
--   win:setFrame(f)
-- end)

-- hs.hotkey.bind({"3", "3"}, "d", function()
--   hs.alert.show("Hello World!")
-- end)

