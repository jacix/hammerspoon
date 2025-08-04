--[[ Stuff I use at home - hammerspoonie@jasons.us
change log:
  2024-03-06 - initial creation, extracted from init.lua - am I even using this?
  2024-03-18 - disabled in liue of music-webserver.lua
--]]
--[[

-- experiment on 2025-06-05 to help with video editing
hotkey_CmdOptY = hs.hotkey.bind({"cmd","alt"}, "Y", function()
  -- hs.eventtap.keyStroke({"cmd"}, "y")
  hs.eventtap.keyStroke({"cmd"}, "y", focused_app)
  hs.timer.usleep(50000)
  hs.eventtap.keyStroke({"cmd"}, "right")
  hs.timer.usleep(50000)
  hs.eventtap.keyStroke({"cmd"}, "left")
end)


hotkey_CmdOptY = hs.hotkey.bind({"cmd","alt"}, "Y", "TrimoTron", function()
  print("sending a y")
  hs.eventtap.keyStroke({"cmd"}, "y")
  -- hs.timer.usleep(50000)
  -- hs.eventtap.keyStroke({"cmd"}, "left")
end)

-- URLs to play and pause music
hs.urlevent.bind("pauseMusic",function(pauseMusic, params)
  if hs.itunes.getPlaybackState() == "kPSP" then
    music_was_playing=True
  else
    music_was_playing=False
  end
  --hs.osascript.applescript('tell application "Music" to pause')
  hs.itunes.pause()
end)
hs.urlevent.bind("playMusic",function(playMusic, params)
  --hs.osascript.applescript('tell application "Music" to play')
  hs.itunes.play()
end)
--]]
