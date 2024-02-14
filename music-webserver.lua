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
* 2024-02-14 - initial creation
]]--
function musicFunction(reqtype, path, headers, body)
  --print(path .. "\n")
  returnCode=200
  if path=="/play" then
    hs.itunes.play()
    returnMessage="played"
  elseif path=="/pause" then
    hs.itunes.pause()
    returnMessage="paused"
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
    if hs.itunes.isPlaying() then
      returnMessage="1"
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
