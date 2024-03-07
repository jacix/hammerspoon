--[[ Stuff I use at home - hammerspoonie@jasons.us
change log:
  2024-03-06 - initial creation, extracted from init.lua - am I even using this?
--]]

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

