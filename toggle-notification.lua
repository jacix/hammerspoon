--[[ author: Jason Schechner - hammerspoonie@jasons.us
Silly script to turn off app notifications within system settings.  When triggered it:
- looks for the proper window. If not found, return with an alert.
- centers notifications on screen
- click the first item on the list
- click the toggle
- go back
- scroll down 6 lines

Is this necessary to automate? When you have hundreds of these things from years of not paying attention - yeah. 
Change log:
* 2024-03-06 - created
--]]

menuTop = {x = 927.10925292969, y = 321.20617675781}
goback = { x = 727.04089355469, y = 259.52630615234 }
toggle = {   x = 1144.4489746094, y = 301.53338623047 }

print("starting")
if hyperT then
  hyperT:delete()
  print("Deleting old toggle key")
else
  print("No toggle key yet.")
end

hyperT = hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "toggle notifications", function()
  notificationsWindow=hs.window.find("Notifications")
  if not notificationsWindow then
    hs.alert("Notifications window missing. Bye")
    return
  end 
  notificationsWindow:centerOnScreen()
  notificationsWindow:focus()
  hs.mouse.absolutePosition(menuTop)
  hs.timer.usleep(400000)
  hs.eventtap.leftClick(menuTop)
  hs.timer.usleep(1000000)
  hs.eventtap.leftClick(toggle) 
  hs.timer.usleep(100000)
  hs.eventtap.leftClick(goback)
  hs.timer.usleep(300000)
  hs.mouse.absolutePosition(menuTop)
  hs.eventtap.scrollWheel({0,-6},{})
end)
