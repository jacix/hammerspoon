--[[ recursive binder - this is going to take more time to grok
-- https://nethuml.github.io/posts/2022/04/hammerspoon-global-leader-key/
-- Install:installSpoonFromRepo("RecursiveBinder")
change log
  2023-04-04 - added helperformat with larger font size - might be nice to move it but not today
               created password retrieval using Keychain Spoon as nested menu under 'p'
               created full date/time options: date/time/both and format: long/short
  2024-03-06 - save object when binding a hotkey  
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
      [spoon.RecursiveBinder.singleKey('l', 'yyyy-mm-dd.hh:ss')] = function() hs.eventtap.keyStrokes(os.date("%Y-%m-%d.%H%M")) end,
      [spoon.RecursiveBinder.singleKey('s', 'yyyymmdd.hhss')] = function() hs.eventtap.keyStrokes(os.date("%Y%m%d.%H%M")) end,
      },
    [spoon.RecursiveBinder.singleKey('d', 'dates+')] = {
      [spoon.RecursiveBinder.singleKey('l', 'yyyy-mm-dd')] = function() hs.eventtap.keyStrokes(os.date("%Y-%m-%d")) end,
      [spoon.RecursiveBinder.singleKey('s', 'yyyymmdd')] = function() hs.eventtap.keyStrokes(os.date("%Y%m%d")) end,
      },
    [spoon.RecursiveBinder.singleKey('t', 'times+')] = {
      [spoon.RecursiveBinder.singleKey('l', 'hh:mm')] = function() hs.eventtap.keyStrokes(os.date("%H:%M")) end,
      [spoon.RecursiveBinder.singleKey('s', 'hhmm')] = function() hs.eventtap.keyStrokes(os.date("%H%M")) end
      }
  },
  [spoon.RecursiveBinder.singleKey('p', 'passwords+')] = {
    [spoon.RecursiveBinder.singleKey('s', 'ssi')] = function() hs.eventtap.keyStrokes(spoon.Keychain:getItem{account="jason.schechner",label="workvpnlogin",service="onelogin"}.password) end,
    [spoon.RecursiveBinder.singleKey('p', 'freeipaprod')] = function() hs.eventtap.keyStrokes(spoon.Keychain:getItem{account="jschechner",label="freeipa",service="ssh",comment="freeipaprod"}.password) end
  }
}

hotkey_OptionSpace = hs.hotkey.bind({'option'}, 'space', "Datenheimer", spoon.RecursiveBinder.recursiveBind(jasonKeyMap))

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
