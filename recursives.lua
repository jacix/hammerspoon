--[[ recursive binder - this is going to take more time to grok
-- https://nethuml.github.io/posts/2022/04/hammerspoon-global-leader-key/
-- Install:installSpoonFromRepo("RecursiveBinder")
change log
  2023-04-04 - added helperformat with larger font size - might be nice to move it but not today
               created password retrieval using Keychain Spoon as nested menu under 'p'
               created full date/time options: date/time/both and format: long/short
  2024-03-06 - save object when binding a hotkey  
  2025-08-06 - change hotkey to control-space to avoid clashing with ChatGPT's default
  2025-10-16 - add 'dbc' to date-enheimer for central time long, remove password leftovers from past job
--]]

hs.loadSpoon("RecursiveBinder")

spoon.RecursiveBinder.helperFormat = {
    atScreenEdge = 2,  -- Bottom edge (default value)
    textStyle = {  -- An hs.styledtext object
     font = {
--         name = "Fira Code",
         size = 38
     }
    }
}

spoon.RecursiveBinder.escapeKey = {{}, 'escape'}  -- Press escape to abort
singleKey = spoon.RecursiveBinder.singleKey

jasonKeyMap = {
  [spoon.RecursiveBinder.singleKey('d', 'datetime+')] = {
    [spoon.RecursiveBinder.singleKey('b', 'both+')] = {
      [spoon.RecursiveBinder.singleKey('l', 'long current')] = function() hs.eventtap.keyStrokes(os.date("%Y-%m-%d.%H%M")) end,
      [spoon.RecursiveBinder.singleKey('s', 'short current')] = function() hs.eventtap.keyStrokes(os.date("%Y%m%d.%H%M")) end,
      [spoon.RecursiveBinder.singleKey('c', 'long CT')] = function() hs.eventtap.keyStrokes(os.date("%Y-%m-%d.%H%M",os.time()-3600) .. " CT") end,
      },
    [spoon.RecursiveBinder.singleKey('d', 'dates+')] = {
      [spoon.RecursiveBinder.singleKey('l', 'yyyy-mm-dd')] = function() hs.eventtap.keyStrokes(os.date("%Y-%m-%d")) end,
      [spoon.RecursiveBinder.singleKey('s', 'yyyymmdd')] = function() hs.eventtap.keyStrokes(os.date("%Y%m%d")) end,
      },
    [spoon.RecursiveBinder.singleKey('t', 'times+')] = {
      [spoon.RecursiveBinder.singleKey('l', 'hh:mm')] = function() hs.eventtap.keyStrokes(os.date("%H:%M")) end,
      [spoon.RecursiveBinder.singleKey('s', 'hhmm')] = function() hs.eventtap.keyStrokes(os.date("%H%M")) end
      }
  }
}

hotkey_OptionSpace = hs.hotkey.bind({'control'}, 'space', "Datenheimer", spoon.RecursiveBinder.recursiveBind(jasonKeyMap))

--[[ basement - storage and references (and probably a bunch of dust)
defaultKeyMap = {
  [spoon.RecursiveBinder.singleKey('b', 'browser')] = function() hs.application.launchOrFocus("Firefox") end,
  [spoon.RecursiveBinder.singleKey('t', 'terminal')] = function() hs.application.launchOrFocus("Terminal") end,
  [spoon.RecursiveBinder.singleKey('d', 'domain+')] = {
    [spoon.RecursiveBinder.singleKey('g', 'github')] = function() hs.urlevent.openURL("github.com") end,
    [spoon.RecursiveBinder.singleKey('y', 'youtube')] = function() hs.urlevent.openURL("youtube.com") end
  }
}
--]]
