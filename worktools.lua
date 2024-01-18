--[[ hammerspoon stuff only necessary at work
change log
  2023-04-06 - teams-linkenator: use 2x shift-tab instead of 1 tab because teams-chat and teams-teams behavior is different
             - teams-linkenator: wait 850ms after pasting to allow for teams-teams' glacial URL check
  2023-05-16 - add hyper-j to print my email address
  2023-08-25 - add hyper-a for aws-confluence linkeneator
  2024-01-03 - teams link-enator: add 50ms sleep after cmd-k and shift-tabs, change 850ms to 500ms before 'return'
  2024-01-17 - add URL dropFortinet; change ping from telapp1 to jump1
--]]

hs.alert.show("Loading work tools")
----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make a Teams-friendly hyperlink
-- to do:
-- * detect whether there's a URL in the pasteboard
-- * detect app in focus and change output accordingly
-- * Figure out how to click in the tex box in the Teams window after creating a link.
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "Teams link-enator", function()
  mypasteboard = hs.pasteboard.getContents()
  focused_window = hs.window.focusedWindow()
  _, _, url, tag = string.find(mypasteboard, "(.*)/(.*)")
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
hs.urlevent.bind("dropFortinet",function(eventName, params)
     fortiIcon = { x=1483; y=-1425 }
     fortiClick = { x=1485; y=-1380 }
     fortiConsole = { x=1485; y=-1200 }
     -- get the original mouse location
     oldmouse=hs.mouse.absolutePosition()
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
     hs.mouse.absolutePosition(oldmouse)
end)
