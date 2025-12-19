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
  2024-06-04 - move spoon ClipboardTool to init.lua; use variable "hyper" where it belongs
  2024-06-11 - Hyper-L: simplify tags for github, jenkins; strip selectors off end of AWS console URLs
  2024-06-12 - Hyper-L: tighten jenkins.teladoc.io URL match; AWS tag handles "view" in addition to "sort"
  2024-06-17 - function closePrivsReminder: check primary screen height to determine X point; wait over X instead of box 
  2024-06-18 - function closePrivsReminder: waiting over X doesn't always work, so wait over box, move to X, click X
  2024-06-28 - add Hyper-D: rename compliance docs based on what's in the pasteboard
  2024-07-11 - Hyper-L: add jenkins-prod2.shared.aws.teladoc.com
  2024-08-06 - closePrivsReminder: handle nul focused_window
  2024-08-28 - 1-step closer to auto-connecting azure vpn; remove clipboard manager
  2024-09-05 - Hyper-L: clean up and generalize jenkins matches = drop "/job" and gsub the URL instead of using capture groups
  2024-09-10 - finally got connectAzure working using Wooshy. It's flaky since the prod VPN sometimes is 4 tabs, sometimes 5. Default here is 4 with 0.2s wait between "tabs" so I can add one live
  2025-08-21 - disabled URLDispatcher since it's not necesary at Traversal
  2025-09-03 - remove tdh stuff (this file was copied as tdh.worktools.lua)
  2025-09-15 - add hotkey_hyperP for pepsi
  2025-09-19 - hyperP looks for "Enter your organization" and now hits enter
  2025-10-23 - re-enable URLDispatcher for app.traversal.com; delete tdh stuff, retire pepsi-o-matic
  2025-12-16 - URLDispatcher: app.traversal.com, staging.traversal.com open with Chrome
  2025-12-19 - Hyper-L: handle trav prod and staging, also paste into Safari for google sheets. Make it more specific later
--]]

-- variables used by multiple bindings, or just here for convenience
primaryScreen=hs.screen.primaryScreen()
my_work_email  = "jason@traversal.com"

-- please allow me to introduce myself
hs.alert.show("Loading work tools")
----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make an application-friendly hyperlink
-- to do:
-- * Figure out how to click in the text box in the Teams window after creating a link.
hotkey_hyperL = hs.hotkey.bind(hyper, "L", "Web link-enator", function()
  -- clear variables
  pr, repo, tag = nil
  -- set variables
  travprodsession = "https://app.traversal.com/session"
  travstgsession = "https://staging.traversal.com/session"
  -- craft a tag from the pasteboard, removing the trailing slash if present
  mypasteboard = hs.pasteboard.getContents():gsub("\n$",""):gsub("/$","")
  if not mypasteboard:match("https?://") then
    hs.alert.show("Clipboard ain't right.\n clipboard: " .. mypasteboard , 4)
    return
  elseif mypasteboard:match("https://github.com") then
    print("link-o-matic: github")
    tag=mypasteboard:gsub("https://github.com/","github/")
  elseif mypasteboard:match(travprodsession) then
    sessionid = mypasteboard:match(travprodsession .. "/([%w%-]*)")
    tag = "P:" .. sessionid
    mypasteboard = travprodsession .. "/" .. sessionid
    print("link-o-matic: trav prod. sessionID=" .. sessionid .. " / pasteboard=" .. mypasteboard)
  elseif mypasteboard:match(travstgdsession) then
    sessionid = mypasteboard:match(travstgsession .. "/([%w%-]*)")
    tag = "P:" .. sessionid
    mypasteboard = travstgsession .. "/" .. sessionid
    print("link-o-matic: trav stg. sessionID=" .. sessionid .. " / pasteboard=" .. mypasteboard)
  --[[
  elseif mypasteboard:match("https://ci.intouchhealth.io/.*/cluster.up/") then
    hs.alert("Matched a cluster.up in the link-o-matic. oops", 4)
    print("Matched a cluster.up in the link-o-matic. oops")
    controller, folder, pipeline, branch, build = mypasteboard:match("https://ci.intouchhealth.io/(.*)/job/(.*)/job/(.*)/job/(.*)/(.*)")
    tag = "jenkins/" .. controller .. "/" .. folder .. "/" .. pipeline .. "/" .. branch .. "/" .. build
  ]]--
  elseif mypasteboard:match("https://.*console.aws.amazon.com") then
    --tag = mypasteboard:match(".*=.*=(.*[0-9a-z])") -- doesn't handle sorting like "...;sort=desc:createTime"
    tag = mypasteboard:gsub(";[sv][oi][re].*",""):match(".*=(.*[0-9a-z])")
    -- also works: tag, _ = mypasteboard:gsub(";sort.*",""):gsub(".*=","")
  elseif mypasteboard:match("https?://") then
    print("link-o-matic: URL catch-all")
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
  elseif (frontmost_app_title == "Microsoft Excel") then
    hs.eventtap.keyStroke({"cmd"}, "k", focused_app)
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "return", focused_app)
  elseif (frontmost_app_title == "Safari") then
    hs.eventtap.keyStroke({"cmd"}, "k", focused_app)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "tab", focused_app)
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({}, "return")
    hs.eventtap.keyStroke({}, "return")
  else
    hs.alert.show("Make me work with:\nApplication: " .. frontmost_app_title .. "\nFocused window: " .. focused_window_title, 4)
  end
end)

-- print my email address
hotkey_hyperJ = hs.hotkey.bind(hyper, "J", "my email", function()
  hs.eventtap.keyStrokes(my_work_email)
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
-- URL Dispatcher to send applications to Chrome when necessary
Install:andUse("URLDispatcher", {
  config = {
    url_patterns = {
      { "staging.traversal.com", "com.google.Chrome" },
      { "app.traversal.com", "com.google.Chrome" }
    },
    default_handler = "com.apple.Safari"
  },
  start = true,
  -- Enable debug logging if you get unexpected behavior
  -- loglevel = 'debug'
})
-- this works but no help in hyper-h
Install:andUse("MicMute", { hotkeys = { toggle = { hyper, "M", "barf" } } })

-- this works, and has help with hyper-h but displays two copies of the menu bar icon
-- hs.loadSpoon("MicMute")
-- hs.spoons.use("MicMute")
-- spoon.MicMute:init() hs.hotkey.bind(hyper, "M", "muteme", function()
--   spoon.MicMute:toggleMicMute()
-- end)

-- copied on 2024-06-19 from https://www.reddit.com/r/hammerspoon/comments/og0tio/move_mouse_linearly
function movemouse(x1,y1,x2,y2,sleep)
  local xdiff = x2 - x1
  local ydiff = y2 - y1
  local loop = math.floor( math.sqrt((xdiff*xdiff)+(ydiff*ydiff)) )
  local xinc = xdiff / loop
  local yinc = ydiff / loop
  sleep = math.floor((sleep * 1000000) / loop)
  for i=1,loop do
    x1 = x1 + xinc
    y1 = y1 + yinc
    hs.mouse.absolutePosition({x = math.floor(x1), y = math.floor(y1)})
    hs.timer.usleep(sleep)
  end
  hs.mouse.absolutePosition({x = math.floor(x2), y = math.floor(y2)})
end

----------------------------------------------------------------------------------------------
--[[ stuff to play with later
hs.tabs.enableForApp("Teams") - https://www.hammerspoon.org/docs/hs.tabs.html
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

-- ## archived 2025-10-23
-- added 2025-09-15
hotkey_hyperP = hs.hotkey.bind(hyper, "P", "Pepsi-login", function()
  focused_window = hs.window.focusedWindow()
  frontmost_app = hs.application.frontmostApplication()
  frontmost_app_title = frontmost_app:title()
  focused_window_title = focused_window:title()
  if frontmost_app_title:match("Safari") then
      if focused_window_title:match("Enter your organization") then
         hs.eventtap.keyStroke({}, "tab", frontmost_app)
         hs.eventtap.keyStrokes("Pepsi", frontmost_app)
         hs.eventtap.keyStroke({}, "return", frontmost_app)
      else
         print("focused window not Traversal, it's " .. frontmost_window_title)
      end
   else
      print("frontmost app is not Safari, it's " .. frontmost_app_title)
   end
end)
]]--
