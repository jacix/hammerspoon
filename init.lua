--[[
Jason's hammerspoon hotkeys

change log:
  2023-03-20 - initial creation with R=reload, W=notify, Q=alert, C=clock
  2023-03-22 - added T=Teams linkinator
  2023-03-24 - added HammerText and ddd, dd, hhh, hh, ddhh; changed output and hotkey for sleep-checker
--]]

----------------------------------------------------------------------------------------------
-- some variables
hyper       = {"cmd","alt","ctrl"}
shift_hyper = {"cmd","alt","ctrl","shift"}
ctrl_cmd    = {"cmd","ctrl"}
-- work_logo = hs.image.imageFromPath(hs.configdir .. "/files/work_logo_2x.png")

----------------------------------------------------------------------------------------------
--[[ supplanted by ctrl_cmd-R in ReloadConfiguration spoon
-- reload the config - simple reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
-- hs.alert.show("Config loaded")
--]]
----------------------------------------------------------------------------------------------
-- load some spoons
hs.loadSpoon("SpoonInstall")
Install=spoon.SpoonInstall

hs.loadSpoon("FadeLogo"):start()

-- hs.loadSpoon("ReloadConfiguration"):start()
Install:andUse("ReloadConfiguration", { hotkeys = { reloadConfiguration = { hyper, "R" } }})

hs.loadSpoon("ClipboardTool"):start()

Install:andUse("KSheet", { hotkeys = { toggle = { hyper, "/", "barf" } } })

ht=hs.loadSpoon("HammerText")
ht.keywords={
  [ "ddd." ] = function() return os.date("%Y-%m-%d") end,
  [ "dd." ] = function() return os.date("%Y%m%d") end,
  [ "hhh." ] = function() return os.date("%H:%M") end,
  [ "hh." ] = function() return os.date("%H%M") end,
  [ "ddhh." ] = function() return os.date("%Y%m%d.%H%M") end,
}

hs.loadSpoon("AClock")
spoon.AClock:init() hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", "A Clock", function()
  spoon.AClock:toggleShow()
end)

----------------------------------------------------------------------------------------------
-- work-in-progress to get a list of windows for finding focus and such
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   --window_list = hs.window.list(allWindows)
--   window_list = hs.window.allWindows()
--   hs.alert.show(window_list)
--   -- hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
-- end)

----------------------------------------------------------------------------------------------
-- show the name of the front-most application. Good for troubleshooting.
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "F", "front-most application", function()
  frontmost_application = hs.application.frontmostApplication()
  frontmost_title = frontmost_application:title()
  hs.alert.show(frontmost_application)
end)

----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make a Teams-friendly hyperlink
-- to do:
-- * detect whether there's a URL in the pasteboard
-- * detect app in focus and change output accordingly
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "Teams link-enator", function()
  mypasteboard = hs.pasteboard.getContents()
  _, _, url, tag = string.find(mypasteboard, "(.*)/(.*)")
  hs.eventtap.keyStroke({"cmd"}, "k")
  hs.eventtap.keyStrokes(tag)
  -- hs.timer.usleep(20000)
  hs.eventtap.keyStroke({}, "tab")
  hs.eventtap.keyStrokes(mypasteboard)
  hs.eventtap.keyStroke({}, "return")
end)

hs.hotkey.showHotkeys({"cmd", "alt", "ctrl"}, "H")

----------------------------------------------------------------------------------------------
-- Create menubar item to toggle disabling of sleep, create URLs to call from scripts, check VPN on startup
caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setTitle("BUZZ")
    else
        caffeine:setTitle("zzz.")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- bind URLs "hammerspoon://{stayup,chill}"
hs.urlevent.bind("stayup",function(eventName, params)
    hs.caffeinate.set("displayIdle",true)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end)

hs.urlevent.bind("chill",function(eventName, params)
    hs.caffeinate.set("displayIdle",false)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end)

-------
-- ht:start() doesn't work here
-------

-- check whether sleep is enabled or not
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", "Is sleep disabled?", function()
--  hs.alert.show(hs.caffeinate.get("displayIdle"))
  if hs.caffeinate.get("displayIdle") then
    hs.alert.show("DisplayIdle disabled. (No sleep till Brooklyn.)")
  else
    hs.alert.show("DisplayIdle enabled. (When is naptime?)")
  end
end)
-------
-- but ht:start() DOES work here - WTF?
-------
ht:start()

-- Check if on VPN when HS starts, and if so, disable sleep
-- courtesy of https://medium.com/@robhowlett/hammerspoon-the-best-mac-software-youve-never-heard-of-40c2df6db0f8
function pingResult(object, message, seqnum, error)
  if message == "didFinish" then
    hs.caffeinate.set("displayIdle",true)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
    hs.alert.show("VPN detected. It's not too late, to buzz it good.")
    hs.timer.usleep(200000)
    avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
    if avg == 0.0 then
      hs.alert.show("No network")
    elseif avg < 200.0 then
      hs.alert.show("Network good (" .. avg .. "ms)")
    elseif avg < 500.0 then
      hs.alert.show("Network meh(" .. avg .. "ms)")
    else
      hs.alert.show("Network bad(" .. avg .. "ms)")
    end
  end
end

hs.network.ping.ping("telapp1.aws2.teladoc.com", 3, 0.2, 1.0, "any", pingResult)

----------------------------------------------------------------------------------------------
-- date-o-matic with hotkey cmd-alt-d
hs.hotkey.bind({"cmd","alt"}, "D", "Datenheimer", function()
  focused_window = hs.window.focusedWindow()
  diditrun, output, codestring = hs.osascript.applescriptFromFile("./dateomatic.applescript")
  focused_window:focus()
  if diditrun then
    hs.eventtap.keyStrokes(output)
  else
    hs.alert.show("Say what?")
  end
end)

--[[ basement: Stuff to keep as a reference
---------- hello world --------------------
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
  _, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said "..reply)
end)

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

--]]
