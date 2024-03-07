--[[
Simple web server running on a Mac to control Apple Music. Play, pause, get artist or track or album. Etc
Original useage is have home-assistant pause music automatically
It's still very rough but it works. Much cleanup and improvement to do.
Jason Schechner - hass@jasons.us

To do
* add a password
* hammerspoon can only use a self-signed cert, so maybe put a proxy or lighttpd in front of it?
* restrict access to local subnet (hs.httpserver.hsminweb can do that but hs.httpserver can't)
* Add ability to set volume explicitly
* create a Spoon?

Changelog
  2024-02-13 - initial creation
  2024-02-14 - 'isPlaying' only queries Music if the app is running. Prevents the query from starting the app.
  2024-03-06 - 'pause' sets var 'music_was_playing'; added 'restart' command to play only if that var is true. Use with hass.
  2024-03-07 - nil 'music_was_playing' on play and if isPlaying() is true; fix missing '/' in restart; fix formatting
]]--
function musicFunction(reqtype, path, headers, body)
  -- reqtype (GET, POST, PUT) not used... yet.
  --print(path .. "\n")
  returnCode=200
  if path=="/play" then
    hs.itunes.play()
    music_was_playing = nil
    returnMessage="played"
  elseif path=="/pause" then
    if hs.itunes.getPlaybackState() == "kPSP" then
      music_was_playing=true
    else
      music_was_playing=nil
    end
    hs.itunes.pause()
    returnMessage="paused"
  elseif path == "/restart" then -- only start music if variable "music_was_playing" is true
    if music_was_playing then
      hs.itunes.play()
      music_was_playing = nil
      returnMessage="restarted"
    end
  elseif path=="/next" then
    hs.itunes.next()
    returnMessage="skipping"
  elseif path=="/previous" then
    hs.itunes.previous()
    returnMessage="going back"
  elseif path=="/currentAlbum" then
    returnMessage=hs.itunes.getCurrentAlbum()
  elseif path=="/currentArtist" then
    returnMessage=hs.itunes.getCurrentArtist()
  elseif path=="/currentTrack" then
    returnMessage=hs.itunes.getCurrentTrack()
  elseif path=="/isPlaying" then
    if hs.application.find("Music",True,True) then
      if hs.itunes.isPlaying() then
        -- if music_was_playing is set and music is started manually, music_was_playing will remain set. Shouldn't happen,
        -- but in case it does, nil music_was_playing when playback is detected.
        music_was_playing=nil
        returnMessage="1"
      else
        returnMessage="0"
      end
    else
      returnMessage="0"
    end
  elseif path=="/isRunning" then
    if hs.itunes.isRunning() then
      returnMessage="1"
    else
      returnMessage="0"
    end
  elseif path=="/volume" then
    returnMessage=hs.itunes.getVolume()
  elseif path=="/volumeUp" then
    hs.itunes.volumeUp()
    returnMessage="up to " .. hs.itunes.getVolume()
  elseif path=="/volumeDown" then
    hs.itunes.volumeDown()
    returnMessage="down to " .. hs.itunes.getVolume()
  else
    returnMessage="uhm. no."
    returnCode=404
  end
  return returnMessage .. "\n", returnCode, {}
end

musicServer=hs.httpserver.new():maxBodySize(1024):setPort(2600):setName("music-server"):setCallback(musicFunction):start()
