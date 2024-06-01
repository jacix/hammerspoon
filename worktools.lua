--[[ hammerspoon stuff only necessary at work
change log
  2023-04-06 - teams-linkenator: use 2x shift-tab instead of 1 tab because teams-chat and teams-teams behavior is different
             - teams-linkenator: wait 850ms after pasting to allow for teams-teams' glacial URL check
  2023-05-16 - add hyper-j to print my email address
  2023-08-25 - add hyper-a for aws-confluence linkeneator
  2024-01-03 - teams link-enator: add 50ms sleep after cmd-k and shift-tabs, change 850ms to 500ms before 'return'
  2024-01-17 - add URL dropFortinet; change ping from telapp1 to jump1
  2024-01-23 - linkenator: make links in Outlook; detect https? in clipboard or missing URL or missing tag
  2024-01-24 - linkenator: make links in confluence; dropFortinet uses app instead of menubar icon; add connectFortinet URL
  2024-01-24 - add URLs loginAzure and dropAzure
  2024-01-25 - add URL vpnMenuItem to set VPN menu item based on which VPN is connected
  2024-01-31 - connectForti sends ".t{return}" to select the right VPN endpoint
  2024-02-02 - connectForti waits for Forticlient to be active in 0.1s spurts instead of blindly sleeping for 2s
  2024-02-06 - add outlook-reminder closenheimer (hyper-O); add URLs for Teams mic and camera mute-o-matic
  2024-02-08 - outlook-reminder-closenheimer converted to function so can be called by hotkey or URL
  2024-02-26 - add teams URLs to hang up, raise/lower hand; change URL names to start with "teams"
  2024-02-28 - add URL handler to shunt Jenkins to Firefox
  2024-03-01 - linkenator: now hyper-L; do github PRs, AWS links; better erroring on missing or bad URL; chop trailing CR; output to JIRA
  2024-03-06 - save hotkey object when binding, move mic-mute here from init.lua, chop trailing / in linkenator
  2024-03-07 - outlook reminder clear-o-matic also clears permissions notice window
  2024-03-12 - fix typo: Leftclick -> leftClick
  2024-03-13 - clipboardtool: store 100 entries, not 250. Add max_entry_size to a comment FFR; hyperL: handle DEVSD portal
  2024-03-26 - connectFortinet/dropFortinet: replace mouse clicks with keystrokes sent directly to the application
  2024-03-27 - ClipboardTool: set max_entry_size=1024
  2024-03-28 - Hyper-L: add custom tag for jenkins pipelines
  2024-05-04 - Hyper-L: add custom tag for shorter jenkins pipelines
  2024-05-28 - removed privs closer from function clearOutlookReminders; created closePrivsReminder as function and URL binding
  2024-05-29 - function closePrivsReminder: return mouse & resume focus; move xy coordinates variable to top of the file
  2024-05-29 - function closePrivsReminder: wasn't always closing, so now move mouse to privs_close_box, click, and move back
  2024-05-30 - add function and urlbinding to toggle permissionizer
  2024-05-31 - Hyper-L: handle Excel (same as Outlook); handle jenkins.teladoc.io (e.g.: cluster.up/platform.up)
--]]

-- variables used by multiple bindings, or just here for convenience
primaryScreen=hs.screen.primaryScreen()
privs_close_x = { x = 1374.40234375, y = 45.69921875 }
privs_close_box = { x = 1386.40234375, y = 56.69921875 }

-- please allow me to introduce myself
hs.alert.show("Loading work tools")
----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make an application-friendly hyperlink
-- to do:
-- * Figure out how to click in the text box in the Teams window after creating a link.
hotkey_hyperT = hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "Old Web link-enator", function()
  hs.alert.show("Nope. hyper-L, genius")
end)

hotkey_hyperL = hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", "Web link-enator", function()
  -- clear variables
  pr, repo, tag = nil
  -- craft a tag from the pasteboard
  mypasteboard = hs.pasteboard.getContents():gsub("\n$",""):gsub("/$","")
  if not mypasteboard:match("https?://") then
    hs.alert.show("Clipboard ain't right.\n clipboard: " .. mypasteboard , 4)
    return
  elseif mypasteboard:match("https://github.com/.*/pull/") then
    --_, _, repo, pr = string.find(mypasteboard, ".*github.com/(.*)/pull/(.*)")
    repo, pr = mypasteboard:match("https://github.com/(.*)/pull/(.*)")
    tag = "PR:" .. repo .. ";" .. pr
  elseif mypasteboard:match("https://github.com") then
    repo = mypasteboard:match("https://github.com/(.*)")
    tag = "GH:" .. repo
  elseif mypasteboard:match("https://jenkins.teladoc.io/job/.*job") then
    eod, folder, pipeline, build = mypasteboard:match("https://jenkins.teladoc.io/job/(.*)/job/(.*)/job/(.*)/(.*)")
    tag = "JK:" .. eod .. ">" .. folder .. ">" .. pipeline .. ">" .. build
  elseif mypasteboard:match("https://ci.intouchhealth.io/.*/cluster.up/") then
    controller, folder, pipeline, branch, build = mypasteboard:match("https://ci.intouchhealth.io/(.*)/job/(.*)/job/(.*)/job/(.*)/(.*)")
    tag = "JK:" .. controller .. ">" .. folder .. ">" .. pipeline .. ">" .. branch .. ">" .. build
  elseif mypasteboard:match("https://ci.intouchhealth.io/.*/job") then
    controller, pipeline, build = mypasteboard:match("https://ci.intouchhealth.io/(.*)/job/(.*)/(.*)")
    tag = "JK:" .. controller .. ">" .. pipeline .. ">" .. build
  elseif mypasteboard:match("https://.*console.aws.amazon.com") then
    tag = mypasteboard:match(".*=.*=(.*[0-9a-z])")
  elseif mypasteboard:match("https?://") then
    tag = string.match(mypasteboard, ".*/(.*)")
  end
  if tag == nil then
    hs.alert.show("URL found but No tag.\n clipboard: " .. mypasteboard, 4)
    return
  end
  -- create a nicely-formatted link in various applications
  focused_window = hs.window.focusedWindow()
  focused_window_title = focused_window:title()
  frontmost_app = hs.application.frontmostApplication()
  frontmost_app_title = frontmost_app:title()
  if frontmost_app_title:match("Microsoft Teams") then
    hs.eventtap.keyStroke({"cmd"}, "k", focused_app)
    hs.timer.usleep(50000)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({"shift"}, "tab", focused_app)
    hs.eventtap.keyStroke({"shift"}, "tab", focused_app)
    -- hs.timer.usleep(50000)
    hs.eventtap.keyStrokes(mypasteboard, focused_app)
    -- hs.timer.usleep(500000)
    hs.eventtap.keyStroke({}, "return")
    focused_window:focus()
  elseif (frontmost_app_title == "Microsoft Outlook") and (focused_window_title:match("jason.schechner@teladoc.com")) then
    hs.eventtap.keyStroke({"cmd"}, "k", focused_app)
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({"shift"}, "tab", focused_app)
    hs.eventtap.keyStroke({"shift"}, "tab", focused_app)
    hs.eventtap.keyStroke({"shift"}, "tab", focused_app)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "return", focused_app)
  elseif (frontmost_app_title == "Microsoft Excel") then
    hs.eventtap.keyStroke({"cmd"}, "k", focused_app)
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "return", focused_app)
  elseif ( focused_window_title:match("CONFLUENCE DATA CENTER") or focused_window_title:match("JIRA DATA CENTER")) then 
    hs.eventtap.keyStrokes("[" .. tag .. "|" .. mypasteboard .. "]")
  elseif ( focused_window_title:match("DevOps Service Desk") ) then
    hs.eventtap.keyStroke({"cmd"}, "k", focused_app)
    hs.eventtap.keyStrokes(mypasteboard, focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "return", focused_app)
  else
    hs.alert.show("Make me work with:\nApplication: " .. frontmost_app_title .. "\nFocused window: " .. focused_window_title, 4)
  end
end)

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
hs.network.ping.ping("jump1.aws2.teladoc.com", 3, 0.2, 1.0, "any", pingResult)

-- print my email address
hotkey_hyperJ = hs.hotkey.bind(hyper, "J", "my email", function()
  hs.eventtap.keyStrokes(my_work_email)
end)

----------------------------------------------------------------------------------------------
-- URLs to launch and drop Fortinet
hs.urlevent.bind("connectFortinet",function(eventName, params)
  hs.application.launchOrFocus("Forticlient")
  while_counter = 0
  local focusedWindow = hs.window.focusedWindow()
  while (not focusedWindow or focusedWindow:title() ~= "FortiClient -- Zero Trust Fabric Agent")
  do
     while_counter=while_counter+1
     focusedWindow = hs.window.focusedWindow()
     hs.timer.usleep(100000)
     if while_counter >= 100 then
          print("Breaking out of watch loop")
          break
     end
  end
  print(while_counter .. " cycles")   
  fortiApplication=hs.application.find("com.fortinet.FortiClient")
  -- hs.timer.usleep(1000000)
  os.execute("sleep 0.5")
  hs.eventtap.keyStroke({}, "tab", fortiApplication)
  --hs.timer.usleep(1000000)
  os.execute("sleep 0.5")
  hs.eventtap.keyStrokes(".t", fortiApplication)
  --hs.timer.usleep(1000000)
  os.execute("sleep 0.5")
  hs.eventtap.keyStroke({}, "tab", fortiApplication)
  hs.eventtap.keyStroke({}, "space", fortiApplication)
end)

hs.urlevent.bind("dropFortinet",function(eventName, params)
  hs.application.launchOrFocus("Forticlient")
  fortiApplication=hs.application.find("com.fortinet.FortiClient")
  hs.timer.usleep(1000000)
  hs.eventtap.keyStroke({}, "tab", fortiApplication)
  hs.eventtap.keyStroke({}, "space", fortiApplication)
  hs.timer.usleep(1000000)
  hs.eventtap.keyStroke({"cmd"}, "q", fortiApplication)
end)

----------------------------------------------------------------------------------------------
-- URLs to launch and drop Azure VPN
hs.urlevent.bind("connectAzure",function(eventName, params)
  -- variables
  azureProdCommercialClick= { x=760; y=314 }
  primaryScreen=hs.screen.primaryScreen()
  -- activities
  mousePosition=hs.mouse.absolutePosition()
  hs.application.launchOrFocus("Azure VPN Client")
  hs.timer.usleep(1000000)
  azureVPNWindow=hs.window.find("Azure VPN Client")
  azureVPNWindow:centerOnScreen(primaryScreen)
  hs.timer.usleep(1000000)
  hs.eventtap.leftClick(azureProdCommercialClick)
  hs.timer.usleep(1000000)
  hs.eventtap.leftClick(azureProdCommercialClick)
  hs.timer.usleep(500000)
  hs.mouse.absolutePosition(mousePosition)
end)

hs.urlevent.bind("dropAzure",function(eventName, params)
  -- variables
  azureProdCommercialClick= { x=760; y=314 }
  primaryScreen=hs.screen.primaryScreen()
  -- activities
  mousePosition=hs.mouse.absolutePosition()
  hs.application.launchOrFocus("Azure VPN Client")
  hs.timer.usleep(500000)
  azureVPNWindow=hs.window.find("Azure VPN Client")
  hs.timer.usleep(500000)
  azureVPNWindow:centerOnScreen(primaryScreen)
  hs.timer.usleep(500000)
  frontapp=hs.application.frontmostApplication()
  if frontapp:name() == "Azure VPN Client" then
    hs.eventtap.leftClick(azureProdCommercialClick)
    hs.timer.usleep(500000)
    hs.eventtap.keyStroke({"cmd"}, "q")
  else
    hs.alert("Not killing " .. frontapp:name() .. " - you're welcome")
  end
  hs.mouse.absolutePosition(mousePosition)
end)

----------------------------------------------------------------------------------------------
-- Add VPN status to the menu bar
vpnMenuStatus=hs.menubar.new()
vpnMenuStatus:setIcon("images/pad-lock-png-free-download-23_20x20.png")

hs.urlevent.bind("vpnMenuItem",function(setVPNMenuItem,params)
  -- hs.alert("I see params" .. hs.inspect(params))
  if params["connected"] == "1" then
    vpnMenuStatus:returnToMenuBar()
    vpnMenuStatus:setTitle(params["service"])
  else
    vpnMenuStatus:removeFromMenuBar()
  end
end)

----------------------------------------------------------------------------------------------
-- Clear Outlook reminders. It's a function so can be called by hotkey or URL
function clearOutlookReminders()
  reminders_window=hs.window.find("Reminder")
  if reminders_window then
    reminders_window:close()
  else
    hs.alert.show("What reminders? (hint: I can't find a reminders window.")
  end
end

hs.urlevent.bind("clearOutlookReminders",function(eventName,params)
  clearOutlookReminders()
end)

hotkey_hyperO = hs.hotkey.bind(hyper, "O", "close outlook reminders", function()
  clearOutlookReminders()
end)

----------------------------------------------------------------------------------------------
-- run privileges and enable
function togglePrivs()
  privsApplication=hs.application.launchOrFocus("Privileges")
  privsApplication=hs.application.find("com.sap.privileges")
  hs.timer.usleep(500000)
  hs.eventtap.keyStroke({}, "tab", privsApplication)
  hs.eventtap.keyStroke({}, "space", privsApplication)
end

hs.urlevent.bind("togglePrivs",function(eventName,params)
  togglePrivs()
end)

----------------------------------------------------------------------------------------------
-- clear the annoying permissions changed notice box. Need to find a way to see if it's present.
function closePrivsReminder()
  mousePosition=hs.mouse.absolutePosition()
  focused_window = hs.window.focusedWindow()
  hs.mouse.absolutePosition(privs_close_box)
  hs.timer.usleep(200000)
  hs.eventtap.leftClick(privs_close_x)
  hs.timer.usleep(200000)
  hs.mouse.absolutePosition(mousePosition)
  focused_window:focus()
end

hs.urlevent.bind("closePrivsReminder",function(eventName,params)
  closePrivsReminder()
end)

----------------------------------------------------------------------------------------------
-- Teams URLs - names should be self-explanatory
hs.urlevent.bind("teamsMuteMic",function(eventName, params)
  hs.eventtap.keyStroke({"cmd", "shift"}, "m",hs.application.find("Microsoft Teams"))
end)

hs.urlevent.bind("teamsMuteCam",function(eventName, params)
  hs.eventtap.keyStroke({"cmd", "shift"}, "o",hs.application.find("Microsoft Teams"))
end)

hs.urlevent.bind("teamsHangup",function(eventName, params)
  hs.eventtap.keyStroke({"cmd", "shift"}, "h",hs.application.find("Microsoft Teams"))
end)

hs.urlevent.bind("teamsToggleHand",function(eventName, params)
  hs.eventtap.keyStroke({"cmd", "shift"}, "k",hs.application.find("Microsoft Teams"))
end)

----------------------------------------------------------------------------------------------
-- URL Dispatcher to send applications to Firefox when necessary
Install:andUse("URLDispatcher", {
  config = {
    url_patterns = {
      { "ci.intouchhealthh.io", "org.mozilla.firefox" }
    },
    default_handler = "com.apple.Safari"
  },
  start = true,
  -- Enable debug logging if you get unexpected behavior
  -- loglevel = 'debug'
})

----------------------------------------------------------------------------------------------
-- clipboard manager
Install:andUse("ClipboardTool", {
  -- config = { menubar_title = "\u{1f4ce}", hist_size = 100, max_entry_size=1024 },
  config = { menubar_title = "\u{1f4ce}", hist_size = 100, max_entry_size=1024 },
  hotkeys = { show_clipboard = { hyper, "V" }}
})
spoon.ClipboardTool:start()

-- this works but no help in hyper-h
Install:andUse("MicMute", { hotkeys = { toggle = { hyper, "M", "barf" } } })

-- this works, and has help with hyper-h but displays two copies of the menu bar icon
-- hs.loadSpoon("MicMute")
-- hs.spoons.use("MicMute")
-- spoon.MicMute:init() hs.hotkey.bind(hyper, "M", "muteme", function()
--   spoon.MicMute:toggleMicMute()
-- end)

----------------------------------------------------------------------------------------------
--[[ WIP
-- 2024-01-24 : raise Azure VPN window, hang up VPN and close it - being done by workvpn.sh so commented out
hs.urlevent.bind("dropAzureVPN",function(eventName, params)
  --azure_vpn_app=hs.application.find("Azure VPN")
  --azure_vpn_app=hs.application.find("com.microsoft.AzureVpnMac")
  hs.application.open("com.microsoft.AzureVpnMac")
  hs.application.launchOrFocus("Azure VPN Client")
  azurevpnwindow=hs.window.find("Azure VPN")
  hs.application.launchOrFocusByBundleID("com.microsoft.AzureVpnMac")
  azurevpnwindow:centerOnScreen()
end)
]]--

----------------------------------------------------------------------------------------------
--[[ basement - storage and other references
--## archived 2024-03-26
hs.urlevent.bind("dropFortinetold",function(eventName, params)
  -- absolute position on the primary screen
  fortiDisconnect = { x=975; y=630 }
  saveMouse=hs.mouse.absolutePosition()
  hs.application.launchOrFocus("Forticlient")
  fortinetWindow=hs.window.find("Forticlient")
  fortinetWindow:centerOnScreen(primaryScreen)
  hs.timer.usleep(500000)
  frontapp=hs.application.frontmostApplication()
  if frontapp:name() == "FortiClient" then
    hs.eventtap.leftClick(fortiDisconnect)
    hs.eventtap.keyStroke({"cmd"}, "q")
  else
    hs.alert("Not killing " .. frontapp:name() .. " - you're welcome")
  end
  hs.mouse.absolutePosition(saveMouse)
end)

--## archived 2024-03-26
-- move to the fortinet icon, right-click to open menu, left click the disconnect - 2024-01-17
hs.urlevent.bind("dropFortinetolder",function(eventName, params)
  fortiIcon = { x=1495; y=11 }
  fortiClick = { x=1497; y=56 }
  fortiConsole = { x=1497; y=236 }
  -- get the original mouse location
  saveMouse=hs.mouse.absolutePosition()
  -- left click the fortinet icon, right-click disconnect
  hs.eventtap.rightClick(fortiIcon)
  hs.timer.usleep(500000)
  hs.eventtap.leftClick(fortiClick)
  -- bring up the console and quit it
  hs.timer.usleep(500000)
  hs.eventtap.rightClick(fortiIcon)
  hs.timer.usleep(500000)
  hs.eventtap.leftClick(fortiConsole)
  hs.timer.usleep(500000)
  frontapp=hs.application.frontmostApplication()
  hs.timer.usleep(500000)
  if frontapp:name() == "FortiClient" then
    hs.eventtap.keyStroke({"cmd"}, "q")
  else
    hs.alert("Not killing " .. frontapp:name() .. " - you're welcome")
  end
  -- move the mouse back
  hs.mouse.absolutePosition(saveMouse)
end)

--## archived 2024-03-26
hs.urlevent.bind("connectFortinetold",function(eventName, params)
  -- variables
  fortiEndpointMenu = { x=987; y=537 }
  fortiTierpoint = { x=957 ; y=600 }
  -- activities
  mousePosition=hs.mouse.absolutePosition()
  hs.application.launchOrFocus("Forticlient")
  while_counter = 0
  local focusedWindow = hs.window.focusedWindow()
  while (not focusedWindow or focusedWindow:title() ~= "FortiClient -- Zero Trust Fabric Agent")
  do
     while_counter=while_counter+1
     focusedWindow = hs.window.focusedWindow()
--[[ checking to see how long I have to wait for forticlient to come into focus; only for debugging
     if focusedWindow then
          print(while_counter .. " : hs.window.focusedWindow():title() = " .. hs.window.focusedWindow():title())
     else
          print(while_counter .. ": No focus.")
     end
     print(while_counter .. " : hs.application.frontmostApplication():title()" .. hs.application.frontmostApplication():title() .. "\n")
--]#]
     hs.timer.usleep(100000)
     if while_counter >= 100 then
          print("Breaking out of watch loop")
          break
     end
  end
  print(while_counter .. " cycles")
  hs.timer.usleep(1000000)
  hs.eventtap.leftClick(fortiEndpointMenu)
  hs.timer.usleep(500000)
  -- hs.eventtap.leftClick(fortiTierpoint)
  hs.eventtap.keyStrokes(".t")
  hs.eventtap.keyStroke({}, "return")
  hs.timer.usleep(600000)
  hs.eventtap.leftClick(fortiTierpoint)
  -- send the mouse back to where it was
  hs.timer.usleep(600000)
  hs.mouse.absolutePosition(mousePosition)
end)
]]--
