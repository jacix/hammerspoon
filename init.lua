--[[ Jason's hammerspoon hotkeys
change log:
  2023-03-20 - initial creation with R=reload, W=notify, Q=alert, C=clock
  2023-03-22 - added T=Teams linkinator
  2023-03-24 - added HammerText, including ddd, dd, hhh, hh, ddhh, awsus, awsca, awsdk
               changed output and hotkey for sleep-checker from hyper-Y to hyper-S
               hyper-V brings up clipboard manager
  2023-03-25 - split out worktools.lua, much cleanup
  2023-05-16 - add variable "my_email" here; currently used in worktools.lua
  2023-07-06 - add "Jason Schechner Y3WLD0C6NF" as alternate hostname for work laptop for loading worktools
  2024-01-18 - add defeat paste blocking = opt-cmd-v
  2024-01-18 - add spoon MicMute
  2024-01-24 - meta-F shows relative and absolute mouse positions
  2024-02-06 - add "hs.application.enableSpotlightForNameSearches(true)"; add front-most window to hyper-F
  2024-02-13 - add URLs to play/pause Music
  2024-02-28 - add bundleID to hyper-F; improve mouse cooridinate output in hyper-F
  2024-03-06 - hyper-F adds vars for relative and absolute mouse positions - useful in console; save hotkey object when binding
               much cleanup; merged Vader's bespoke init.lua by:
                 mic-mute, clipboard manager to worktools; music URLs to hometools; vader loads music-webserver
  2024-03-18 - add mouseHighlight as hyper-shift-M; minor basement cleanup
  2024-03-26 - hyper-F: add PIDs, roles, IDs
  2024-06-03 - add m3po
--]]
----------------------------------------------------------------------------------------------
-- some variables
hyper          = {"cmd","alt","ctrl"}
shift_hyper    = {"cmd","alt","ctrl","shift"}
ctrl_cmd       = {"cmd","ctrl"}
my_email       = "hammerspoonie@jasons.us"
my_work_email  = "jason.schechner@teladochealth.com"
-- work_logo = hs.image.imageFromPath(hs.configdir .. "/files/work_logo_2x.png")

----------------------------------------------------------------------------------------------
-- load some spoons
hs.loadSpoon("SpoonInstall")
Install=spoon.SpoonInstall
-- update the default spoons repo (hammerspoon.org/Spoons)
Install:updateRepo('default')
-- aka: spoon.SpoonInstall:updateRepo('default')

hs.loadSpoon("FadeLogo"):start()

-- hs.loadSpoon("ReloadConfiguration"):start()
Install:andUse("ReloadConfiguration", { hotkeys = { reloadConfiguration = { hyper, "R" }, "Reload" }})

----------------------------------------------------------------------------------------------
-- determine my hostname, so I know what to load
myhostname = hs.host.localizedName()
if myhostname == "REM-JasonSchechner" or myhostname == "Jason Schechner Y3WLD0C6NF" then
  local workstuff = require('worktools')
elseif myhostname == "vader" or myhostname == "m3po" then
  local homestuff = require('hometools')
  local homestuff = require('music-webserver')
else
  hs.alert("I don't recognize " .. myhostname .. " so not loading work or home tools.",4)
end

Install:andUse("KSheet", { hotkeys = { toggle = { hyper, "/", "barf" } } })

----------------------------------------------------------------------------------------------
-- pull items from keychain
-- the following two lines could be replaced by: Install:andUse("Keychain")
spoon.SpoonInstall:installSpoonFromRepo("Keychain")
hs.spoons.use("Keychain")

----- recursive binder - this is going to take more time to grok, so start with a datenheimer
-- https://nethuml.github.io/posts/2022/04/hammerspoon-global-leader-key/
Install:installSpoonFromRepo("RecursiveBinder")
local recursives = require("recursives")
--[[
spoon.RecursiveBinder.helperFormat = {
    atScreenEdge = 2,  -- Bottom edge (default value)
    textStyle = {  -- An hs.styledtext object
	  font = {
	    name = "Fira Code",
	    size = 18
	  }
    }
}
--]]

hs.loadSpoon("AClock")
spoon.AClock:init() hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", "A Clock", function()
  spoon.AClock:toggleShow()
end)
----------------------------------------------------------------------------------------------
-- general purpose stuff  --------------------------------------------------------------------
-- enable Spotlight support
hs.application.enableSpotlightForNameSearches(true)
-- show registered hotkeys
hotkey_HyperH = hs.hotkey.showHotkeys({"cmd", "alt", "ctrl"}, "H")

-- show the name of the front-most application. Good for troubleshooting.
hotkey_HyperF = hs.hotkey.bind({"cmd", "alt", "ctrl"}, "F", "front-most app+window; focused window", function()
  -- These calls can be made in alert.show, but for troubleshooting you can ref them in the console
  frontmost_application = hs.application.frontmostApplication()
  frontmost_window = hs.window.frontmostWindow()
  focused_window = hs.window.focusedWindow()
  relative_mouse = hs.mouse.getRelativePosition()
  absolute_mouse = hs.mouse.absolutePosition()
  hs.alert.show("- frontmost_app bundleID: " .. frontmost_application:bundleID() .. "\n- frontmost_app title: " .. frontmost_application:title() .. "\n- frontmost_app pid, role: " .. frontmost_application:pid() .. ", " .. frontmost_application:role() .. "\n- frontmost_win title: " .. frontmost_window:title() .. "\n-frontmost_win pid, id, role: " .. frontmost_window:pid() .. ", " .. frontmost_window:id() .. ", " .. frontmost_window:role() .. "\n- focused_win title: " .. focused_window:title() .. "\n- Mouse relative: x = " .. relative_mouse["x"] .. ", y = " .. relative_mouse["y"] .. "  //  absolute: x = " .. absolute_mouse["x"] .. ", y = " .. absolute_mouse["y"], 6)
end)

-- Create menubar item to toggle disabling of sleep, create URLs to call from scripts
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
-- HK to check whether sleep is enabled or not
hotkey_HyperS = hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", "Is sleep disabled?", function()
  if hs.caffeinate.get("displayIdle") then
    hs.alert.show("DisplayIdle disabled. (No sleep till Brooklyn.)")
  else
    hs.alert.show("DisplayIdle enabled. (When is naptime?)")
  end
end)

-- work-in-progress to get a list of windows for finding focus and such; useful? dunno
--[[
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  --window_list = hs.window.list(allWindows)
  window_list = hs.window.allWindows()
  hs.alert.show(window_list)
end)
--]]

----------------------------------------------------------------------------------------------
-- defeat paste blocking - https://www.hammerspoon.org/go/#pasteblock - 2024-01-17
hotkey_CmdAltV = hs.hotkey.bind({"cmd", "alt"}, "V", "defeat paste block", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

----------------------------------------------------------------------------------------------
-- mouse finder - https://www.hammerspoon.org/go/#pasteblock - 2024-03-18
mouseCircle = nil
mouseCircleTimer = nil

function mouseHighlight()
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.absolutePosition()
    -- Prepare a big red circle around the mouse pointer
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    -- Set a timer to delete the circle after 3 seconds
    mouseCircleTimer = hs.timer.doAfter(3, function()
      mouseCircle:delete()
      mouseCircle = nil
    end)
end
hotkey_ShiftHyperM = hs.hotkey.bind(shift_hyper, "M", "MouseFinder", mouseHighlight)

------------------------------------------------------------------------------------------------------------------------
--[[ basement: storage and references (and maybe hidden treasures)
---------- hello world --------------------
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
  _, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said "..reply)
end)

---- post message to notification center ----------------------------------------------------
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)
----------------------------------------------------------------------------------------------
-- supplanted by ctrl_cmd-R in ReloadConfiguration spoon
-- reload the config - simple reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
-- hs.alert.show("Config loaded")
----------------------------------------------------------------------------------------------
-- test pop-up
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
_, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said ".. reply)
end)
----------------------------------------------------------------------------------------------
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK")
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK", "Cancel")
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "", "OK", "Cancel", true)
----------------------------------------------------------------------------------------------
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", "move focused window a bit", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  win:setFrame(f)
end)
----------------------------------------------------------------------------------------------
--[[ disabled in lieu of RecursiveBinder
ht=hs.loadSpoon("HammerText")
ht.keywords={
  [ "ddd." ] = function() return os.date("%Y-%m-%d") end,
  [ "dd." ] = function() return os.date("%Y%m%d") end,
  [ "hhh." ] = function() return os.date("%H:%M") end,
  [ "hh." ] = function() return os.date("%H%M") end,
  [ "dh." ] = function() return os.date("%Y%m%d.%H%M") end,
  [ "ddhh." ] = function() return os.date("%Y-%m-%d.%H%M") end,
}
ht:start()
--]]

----------------------------------------------------------------------------------------------
--[[ disabled 2024-03-06 - RecursiveBinder is better (I forgot this was even here.)
hotkey_CmdAltD = hs.hotkey.bind({"cmd","alt"}, "D", "Datenheimer", function()
  focused_window = hs.window.focusedWindow()
  diditrun, output, codestring = hs.osascript.applescriptFromFile("./dateomatic.applescript")
  focused_window:focus()
  if diditrun then
    hs.eventtap.keyStrokes(output)
  else
    hs.alert.show("Say what?")
  end
end)
--]]
