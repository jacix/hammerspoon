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
--]]

----------------------------------------------------------------------------------------------
-- some variables
hyper       = {"cmd","alt","ctrl"}
shift_hyper = {"cmd","alt","ctrl","shift"}
ctrl_cmd    = {"cmd","ctrl"}
my_email    = "jason.schechner@teladochealth.com"
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

Install:andUse("ClipboardTool", {
  config = { menubar_title = "\u{1f4ce}",
             hist_size = 250},
  hotkeys = { show_clipboard = { hyper, "V" }}
  })
spoon.ClipboardTool:start()

Install:andUse("KSheet", { hotkeys = { toggle = { hyper, "/", "barf" } } })

----------------------------------------------------------------------------------------------
-- pull items from keychain
-- the following two lines could be replaced by: Install:andUse("Keychain")
spoon.SpoonInstall:installSpoonFromRepo("Keychain")
hs.spoons.use("Keychain")

----- recursive binder - this is going to take more time to grok
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


--[[
ht=hs.loadSpoon("HammerText")
ht.keywords={
  [ "ddd." ] = function() return os.date("%Y-%m-%d") end,
  [ "dd." ] = function() return os.date("%Y%m%d") end,
  [ "hhh." ] = function() return os.date("%H:%M") end,
  [ "hh." ] = function() return os.date("%H%M") end,
  [ "dh." ] = function() return os.date("%Y%m%d.%H%M") end,
  [ "ddhh." ] = function() return os.date("%Y-%m-%d.%H%M") end,
  [ "awsus."]  = "aws2.teladoc.com",
  [ "awsca."] = "aws.teladoc.com",
  [ "awsdk."] = "aws.teladoc.dk",
}
--]]

hs.loadSpoon("AClock")
spoon.AClock:init() hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", "A Clock", function()
  spoon.AClock:toggleShow()
end)
----------------------------------------------------------------------------------------------
-- general purpose stuff  --------------------------------------------------------------------
-- show registered hotkeys
hs.hotkey.showHotkeys({"cmd", "alt", "ctrl"}, "H")

-- show the name of the front-most application. Good for troubleshooting.
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "F", "front-most application", function()
  frontmost_application = hs.application.frontmostApplication()
  frontmost_title = frontmost_application:title()
  hs.alert.show(frontmost_application)
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
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", "Is sleep disabled?", function()
  if hs.caffeinate.get("displayIdle") then
    hs.alert.show("DisplayIdle disabled. (No sleep till Brooklyn.)")
  else
    hs.alert.show("DisplayIdle enabled. (When is naptime?)")
  end
end)

----------------------------------------------------------------------------------------------
-- work-in-progress to get a list of windows for finding focus and such
--[[
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  --window_list = hs.window.list(allWindows)
  window_list = hs.window.allWindows()
  hs.alert.show(window_list)
end)
--]]

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

----------------------------------------------------------------------------------------------
-- determine my hostname, so I know what to load
myhostname = hs.host.localizedName()
if myhostname == "REM-JasonSchechner" or myhostname == "Jason Schechner Y3WLD0C6NF" then
     local workstuff = require('worktools')
end

--[[
ht:start()
--]]

--[[ basement: Stuff to keep as a reference
---------- hello world --------------------
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
  _, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said "..reply)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)
----------------------------------------------------------------------------------------------

supplanted by ctrl_cmd-R in ReloadConfiguration spoon
-- reload the config - simple reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
-- hs.alert.show("Config loaded")
----------------------------------------------------------------------------------------------

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Q", function()
  hs.alert.show("Hello World!")
end)
----------------------------------------------------------------------------------------------

-- test pop-up
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
_, reply = hs.dialog.textPrompt("Main message.", "Please enter something:")
  hs.alert.show("you said "..reply)
end)
----------------------------------------------------------------------------------------------

-- hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK")
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK", "Cancel")
-- hs.dialog.textPrompt("Main message.", "Please enter something:", "", "OK", "Cancel", true)
----------------------------------------------------------------------------------------------

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  win:setFrame(f)
end)

--]]
