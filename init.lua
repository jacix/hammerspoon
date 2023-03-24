--[[ 
Jason's hammerspoon hotkeys

change log:
  2023-03-20 - initial creation with R=reload, W=notify, Q=alert, C=clock
  2023-03-22 - added T=Teams linkinator
--]] 
----------------------------------------------------------------------------------------------
-- reload the config - simple reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

----------------------------------------------------------------------------------------------
-- load some spoons
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall:start()

hs.loadSpoon("ClipboardTool")
spoon.ClipboardTool:start()

----------------------------------------------------------------------------------------------
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   --window_list = hs.window.list(allWindows)
--   window_list = hs.window.allWindows()
--   hs.alert.show(window_list)
--   -- hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
-- end)

-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Q", function()
--   hs.alert.show("Hello World!")
-- end)

----------------------------------------------------------------------------------------------
-- show the name of the front-most application. Good for troubleshooting.
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "F", function()
  frontmost_application = hs.application.frontmostApplication()
  frontmost_title = frontmost_application:title()
  hs.alert.show(frontmost_application)
end)

----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make a Teams-friendly hyperlink
-- to do:
-- * detect whether there's a URL in the pasteboard
-- * detect app in focus and change output accordingly
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "Teamenheimer!", function()
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

hs.hotkey.showHotkeys({"cmd", "alt", "ctrl"}, "H")

----------------------------------------------------------------------------------------------
-- Create menubar item to toggle disabling of sleep
caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setTitle("AWAKE")
    else
        caffeine:setTitle("SLEEPY")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- bind URLs "hammerspoon://{stayup,chill}" to enable/diable sleep that can be called from scripts, etc
hs.urlevent.bind("stayup",function(eventName, params)
    hs.caffeinate.set("displayIdle",true)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end)

hs.urlevent.bind("chill",function(eventName, params)
    hs.caffeinate.set("displayIdle",false)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end)

-- cmd-alt-ctrl-V checks whether sleep is enabled or not
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "V", function()
  hs.alert.show(hs.caffeinate.get("displayIdle"))
end)
----------------------------------------------------------------------------------------------
-- date-o-matic
hs.hotkey.bind({"cmd","alt"}, "D", function()
  focused_window = hs.window.focusedWindow()
  diditrun, output, codestring = hs.osascript.applescriptFromFile("./dateomatic.applescript")
  focused_window:focus()
  hs.eventtap.keyStrokes(output)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
  _, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said "..reply)
end)

--[[ basement: Stuff to keep as a reference

---------- hello world --------------------
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Q", function()
  hs.alert.show("Hello World!")
end)

-- test pop-up
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
_, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said "..reply)
end)

-- hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK")
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK", "Cancel")
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "", "OK", "Cancel", true)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = f.x - 10
  win:setFrame(f)
end)

hs.hotkey.bind({"3", "3"}, "d", function()
  hs.alert.show("Hello World!")
end)

--]]
