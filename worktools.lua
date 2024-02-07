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
--]]

-- variables used by multiple bindings
primaryScreen=hs.screen.primaryScreen()

-- please allow me to introduce myself
hs.alert.show("Loading work tools")
----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make an application-friendly hyperlink
-- to do:
-- * Figure out how to click in the tex box in the Teams window after creating a link.
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "Web link-enator", function()
  mypasteboard = hs.pasteboard.getContents()
  focused_window = hs.window.focusedWindow()
  focused_window_title = focused_window:title()
  frontmost_app_title = hs.application.frontmostApplication():title()
  _, _, url, tag = string.find(mypasteboard, "(.*)/(.*)")
  badurl=nil
  if url == nil then
    url="(nil url)"
    badurl=1
  end
  if tag == nil then
    tag="(nil tag)"
    badurl=1
  end
  if not mypasteboard:match("https?://") then
    badurl=1
  end
    if badurl==1 then
    hs.alert.show("Clipboard ain't right.\nclipboard: " .. mypasteboard .. "\nurl: " .. url .. "\ntag: " .. tag,4)
    return
  end
  if frontmost_app_title:match("Microsoft Teams") then
    hs.eventtap.keyStroke({"cmd"}, "k")
    hs.timer.usleep(50000)
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({"shift"}, "tab")
    hs.eventtap.keyStroke({"shift"}, "tab")
    hs.timer.usleep(50000)
    hs.eventtap.keyStrokes(mypasteboard)
    hs.timer.usleep(500000)
    hs.eventtap.keyStroke({}, "return")
    focused_window:focus()
  elseif focused_window_title:match("jason.schechner@teladoc.com") then
    hs.eventtap.keyStroke({"cmd"}, "k")
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({"shift"}, "tab")
    hs.eventtap.keyStroke({"shift"}, "tab")
    hs.eventtap.keyStroke({"shift"}, "tab")
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "return")
  elseif focused_window_title:match("CONFLUENCE DATA CENTER") then
    hs.eventtap.keyStroke({"cmd"}, "k")
    hs.timer.usleep(10000)
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({}, "tab")
    hs.timer.usleep(10000)
    hs.eventtap.keyStrokes(tag)
    hs.timer.usleep(10000)
    hs.eventtap.keyStroke({}, "return")
  else
    hs.alert.show("Make me work with:\nApplication: " .. frontmost_app_title .. "\nFocused window: " .. focused_window_title, 4)
  end
end)

----------------------------------------------------------------------------------------------
-- take an AWS URL from the clipboard and make a confluence-friendly hyperlink
-- to do:
-- * detect whether there's an AWS URL in the pasteboard
-- * detect app in focus and change output accordingly
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", "AWS-confluence link-enator", function()
  mypasteboard = hs.pasteboard.getContents()
  focused_window = hs.window.focusedWindow()
  tag = string.match(mypasteboard, ".*=.*=(.*[0-9a-z])")
  hs.timer.usleep(75000)
  hs.eventtap.keyStrokes("["..tag.."|"..mypasteboard.."]")
  focused_window:focus()
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
hs.hotkey.bind(hyper, "J", "my email", function()
  hs.eventtap.keyStrokes(my_email)
end)
----------------------------------------------------------------------------------------------
-- move to the fortinet icon, right-click to open menu, left click the disconnect - 2024-01-17
hs.urlevent.bind("dropFortinetold",function(eventName, params)
--     fortiIcon = { x=1483; y=-1425 }
--     fortiClick = { x=1485; y=-1380 }
--     fortiConsole = { x=1485; y=-1200 }
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

hs.urlevent.bind("dropFortinet",function(eventName, params)
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

-- launch fortivpn and log in
hs.urlevent.bind("connectFortinet",function(eventName, params)
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
--[[
     if focusedWindow then
          print(while_counter .. " : hs.window.focusedWindow():title() = " .. hs.window.focusedWindow():title())
     else
          print(while_counter .. ": No focus.")
     end
     print(while_counter .. " : hs.application.frontmostApplication():title()" .. hs.application.frontmostApplication():title() .. "\n")
--]]
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

hs.hotkey.bind(hyper, "O", "close outlook reminders", function()
  reminders_window=hs.window.find("Reminder")
  if reminders_window then
    reminders_window:close()
  else
    hs.alert.show("What reminders? (hint: I can't find a reminders window.")
  end
end)


hs.urlevent.bind("muteTeamsMic",function(eventName, params)
  hs.eventtap.keyStroke({"cmd", "shift"}, "m",hs.application.find("Microsoft Teams"))
end)

hs.urlevent.bind("muteTeamsCam",function(eventName, params)
  hs.eventtap.keyStroke({"cmd", "shift"}, "o",hs.application.find("Microsoft Teams"))
end)

--[[
hs.urlevent.bind("vpnMenuItem",function(eventName,params)
  -- usage: vpnMenuItem?connected=1&service=forti
  hs.alert("I see params" .. hs.inspect(params))
    vpnMenuStatus:returnToMenuBar()
  else
    vpnMenuStatus:removeFromMenuBar()
    vpnMenuStatus:setTitle(params["service"])
  end
end)

--[[
----------------------------------------------------------------------------------------------
-- raise Azure VPN window, hang up VPN and close it - 2024-01-24
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
