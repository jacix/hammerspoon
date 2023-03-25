-- hammerspoon stuff only necessary at work
hs.alert.show("Loading work tools")
----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make a Teams-friendly hyperlink
-- to do:
-- * detect whether there's a URL in the pasteboard
-- * detect app in focus and change output accordingly
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", "Teams link-enator", function()
  mypasteboard = hs.pasteboard.getContents()
  _, _, url, tag = string.find(mypasteboard, "(.*)/(.*)")
  hs.eventtap.keyStroke({"cmd"}, "k")
  hs.eventtap.keyStrokes(tag)
  -- hs.timer.usleep(20000)
  hs.eventtap.keyStroke({}, "tab")
  hs.eventtap.keyStrokes(mypasteboard)
  hs.eventtap.keyStroke({}, "return")
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
hs.network.ping.ping("telapp1.aws2.teladoc.com", 3, 0.2, 1.0, "any", pingResult)

----------------------------------------------------------------------------------------------

