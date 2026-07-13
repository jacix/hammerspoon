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
  2024-02-08 - outlook-reminder-closenheimer converted to function so can be called by hotkey or URL
  2024-02-26 - add teams URLs to hang up, raise/lower hand; change URL names to start with "teams"
  2024-02-28 - add URL handler to shunt Jenkins to Firefox
  2024-03-01 - linkenator: now hyper-L; do github PRs, AWS links; better erroring on missing or bad URL; chop trailing CR; output to JIRA
  2024-03-06 - save hotkey object when binding, move mic-mute here from init.lua, chop trailing / in linkenator
  2024-03-07 - outlook reminder clear-o-matic also clears permissions notice window
  2024-03-12 - fix typo: Leftclick -> leftClick
  2024-03-13 - clipboardtool: store 100 entries, not 250. Add max_entry_size to a comment FFR; hyperL: handle DEVSD portal
  2024-03-26 - connectFortinet/dropFortinet: replace mouse clicks with keystrokes sent directly to the application
  2024-03-27 - ClipboardTool: set max_entry_size=1024
  2024-03-28 - Hyper-L: add custom tag for jenkins pipelines
  2024-05-04 - Hyper-L: add custom tag for shorter jenkins pipelines
  2024-05-28 - removed privs closer from function clearOutlookReminders; created closePrivsReminder as function and URL binding
  2024-05-29 - function closePrivsReminder: return mouse & resume focus; move xy coordinates variable to top of the file
  2024-05-29 - function closePrivsReminder: wasn't always closing, so now move mouse to privs_close_box, click, and move back
  2024-05-30 - add function and urlbinding to toggle permissionizer
  2024-05-31 - Hyper-L: handle Excel (same as Outlook); handle jenkins.teladoc.io (e.g.: cluster.up/platform.up)
  2024-06-04 - move spoon ClipboardTool to init.lua; use variable "hyper" where it belongs
  2024-06-11 - Hyper-L: simplify tags for github, jenkins; strip selectors off end of AWS console URLs
  2024-06-12 - Hyper-L: tighten jenkins.teladoc.io URL match; AWS tag handles "view" in addition to "sort"
  2024-06-17 - function closePrivsReminder: check primary screen height to determine X point; wait over X instead of box
  2024-06-18 - function closePrivsReminder: waiting over X doesn't always work, so wait over box, move to X, click X
  2024-06-28 - add Hyper-D: rename compliance docs based on what's in the pasteboard
  2024-07-11 - Hyper-L: add jenkins-prod2.shared.aws.teladoc.com
  2024-08-06 - closePrivsReminder: handle nul focused_window
  2024-08-28 - 1-step closer to auto-connecting azure vpn; remove clipboard manager
  2024-09-05 - Hyper-L: clean up and generalize jenkins matches = drop "/job" and gsub the URL instead of using capture groups
  2024-09-10 - finally got connectAzure working using Wooshy. It's flaky since the prod VPN sometimes is 4 tabs, sometimes 5. Default here is 4 with 0.2s wait between "tabs" so I can add one live
  2025-08-21 - disabled URLDispatcher since it's not necesary at Traversal
  2025-09-03 - remove tdh stuff (this file was copied as tdh.worktools.lua)
  2025-09-15 - add hotkey_hyperP for pepsi
  2025-09-19 - hyperP looks for "Enter your organization" and now hits enter
  2025-10-23 - re-enable URLDispatcher for app.traversal.com; delete tdh stuff, retire pepsi-o-matic
  2025-12-16 - URLDispatcher: app.traversal.com, staging.traversal.com open with Chrome
  2025-12-19 - Hyper-L: handle trav prod and staging, also paste into Safari for google sheets. Make it more specific later
  2026-01-05 - Hyper-L: fix typo in travstgsession elseif
  2026-01-06 - Hyper-L: handle paste into Slack and Notion; more TDH cleanup; swap MicMute launch method
  2026-03-02 - Hyper-L: handle github PRs
  2026-03-19 - Hyper-L: instead of Safari in app name, look for "Google Sheets" in window title
  2026-03-24 - Hyper-L: handle cap1 URLs
  2026-03-30 - Hyper-L: handle Notion URLs
  2026-07-07 - Hyper-L: Much cleaner paste for Notion and Slack (thanks Claude!); Use more locals; nil-safe the variables; add traversal dev
  2026-07-08 - Hyper-M: Spoon has hand-crafted binder which ignores comments. Bind manually instead - old school.
  2026-07-13 - Hyper-L: Cleaner, more genearlized traversal URL match with table for environments instead of repeated if/thens. More attention to local vs. global vars
--]]

-- variables used by multiple bindings, or just here for convenience
primaryScreen=hs.screen.primaryScreen()
my_work_email  = "jason@traversal.com"

-- please allow me to introduce myself
hs.alert.show("Loading work tools")
----------------------------------------------------------------------------------------------
-- take a URL from the clipboard and make an application-friendly hyperlink
hotkey_hyperL = hs.hotkey.bind(hyper, "L", "Web link-enator", function()
  -- Table of traversal environments. Format: (environment).traversal.com/session = tag_prefix
  local trav_tags = {
    app        = "prd",
    staging    = "stg",
    dev        = "dev",
    capitalone = "cap1",
    testing-3  = "test3",
    payward    = "payward",
  }
  -- copy pasteboard into temporary variable, removing trailing newline and slash if present
  mypasteboard = hs.pasteboard.getContents():gsub("\n$",""):gsub("/$","")
  -- craft a tag from mypasteboard
  tag = nil
  if not mypasteboard:match("https?://") then
    hs.alert.show("Clipboard ain't right.\n clipboard: " .. mypasteboard , 4)
    return
  elseif mypasteboard:match("https://github.com/InteractionLabs/.*/pull") then
    print("link-o-matic: github-pr")
    tag = mypasteboard:gsub("https://github.com/InteractionLabs/","PR:"):gsub("/pull/","/")
  elseif mypasteboard:match("https://github.com") then
    print("link-o-matic: github")
    tag=mypasteboard:gsub("https://github.com/","github/")
  elseif mypasteboard:match("^https://([%w%-]+)%.traversal%.com/session/([%w%-]+)") then
    local env, sessionid = mypasteboard:match("^https://([%w%-]+)%.traversal%.com/session/([%w%-]+)")
    local prefix = trav_tags[env] or env
    tag = prefix .. ":" .. sessionid
    print(("link-o-matic: trav %s sessionID=%s / tag=%s / pasteboard=%s"):format(prefix, sessionid, tag, mypasteboard))
  elseif mypasteboard:match("https://www.notion.so") then
    print("link-o-matic: notion")
    tag = "Notion:" .. mypasteboard:match("notion%.so/([%a%d%-]+)%-%x+$")
  elseif mypasteboard:match("https://.*console.aws.amazon.com") then
    --tag = mypasteboard:match(".*=.*=(.*[0-9a-z])") -- doesn't handle sorting like "...;sort=desc:createTime"
    tag = mypasteboard:gsub(";[sv][oi][re].*",""):match(".*=(.*[0-9a-z])")
    -- also works: tag, _ = mypasteboard:gsub(";sort.*",""):gsub(".*=","")
  else
    print("link-o-matic: URL catch-all")
    tag = string.match(mypasteboard, ".*/(.*)")
  end
  if tag == nil then
    hs.alert.show("URL found but No tag.\n clipboard: " .. mypasteboard, 4)
    return
  end
  -- create a nicely-formatted link in various applications
  local focused_window = hs.window.focusedWindow()
  -- if focused_window is nil, focused_window_title becomes "" to prevent an error
  local focused_window_title = focused_window and focused_window:title() or ""
  local frontmost_app = hs.application.frontmostApplication()
  local frontmost_app_title = frontmost_app:title()
  if (frontmost_app_title == "Microsoft Excel") then
    hs.eventtap.keyStroke({"cmd"}, "k")
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({}, "tab")
    hs.eventtap.keyStroke({}, "tab")
    hs.eventtap.keyStroke({}, "tab")
    hs.eventtap.keyStroke({}, "tab")
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "return")
  elseif focused_window_title:match("Google Sheets") then
    hs.eventtap.keyStroke({"cmd"}, "k")
    hs.eventtap.keyStrokes(tag)
    hs.eventtap.keyStroke({}, "tab")
    hs.eventtap.keyStrokes(mypasteboard)
    hs.eventtap.keyStroke({}, "return")
    hs.eventtap.keyStroke({}, "return")
  elseif (frontmost_app_title == "Notion" or frontmost_app_title:match("Slack") ) then
    -- Notion and Slack prefer public.html flavor if available in the clipboard, so populate that in addition to the standard public.utf8-plain-text.
    -- They'll grab the full, tagged URL while other applications see the standard flavor. see it in the HS console with
    -- return hs.inspect(hs.pasteboard.readAllData())
    hs.pasteboard.writeAllData({
      ["public.html"]            = ('<a href="%s">%s</a>'):format(mypasteboard, tag),
      ["public.utf8-plain-text"] = mypasteboard,
    })
    hs.eventtap.keyStroke({"cmd"}, "v")
    hs.eventtap.keyStroke({}, "space")   -- dismiss Notion's "fancify" offer and add the necessary space
    hs.timer.doAfter(0.3, function() hs.pasteboard.setContents(mypasteboard) end)  -- leave only the URL
  else
    hs.alert.show("Make me work with:\nApplication: " .. frontmost_app_title .. "\nFocused window: " .. focused_window_title, 4)
  end
end)

-- print my email address
hotkey_hyperJ = hs.hotkey.bind(hyper, "J", "my email", function()
  hs.eventtap.keyStrokes(my_work_email)
end)

----------------------------------------------------------------------------------------------
-- URL Dispatcher to send applications to Chrome when necessary
Install:andUse("URLDispatcher", {
  config = {
    url_patterns = {
      { "staging.traversal.com", "com.google.Chrome" },
      { "app.traversal.com", "com.google.Chrome" }
    },
    default_handler = "com.apple.Safari"
  },
  start = true,
  -- Enable debug logging if you get unexpected behavior
  -- loglevel = 'debug'
})

----------------------------------------------------------------------------------------------
Install:andUse("MicMute")
hotkey_hyperM = hs.hotkey.bind(hyper, "M", "muteme", function()
  spoon.MicMute:toggleMicMute()
end)

-- copied on 2024-06-19 from https://www.reddit.com/r/hammerspoon/comments/og0tio/move_mouse_linearly
function movemouse(x1,y1,x2,y2,sleep)
  local xdiff = x2 - x1
  local ydiff = y2 - y1
  local loop = math.floor( math.sqrt((xdiff*xdiff)+(ydiff*ydiff)) )
  local xinc = xdiff / loop
  local yinc = ydiff / loop
  sleep = math.floor((sleep * 1000000) / loop)
  for i=1,loop do
    x1 = x1 + xinc
    y1 = y1 + yinc
    hs.mouse.absolutePosition({x = math.floor(x1), y = math.floor(y1)})
    hs.timer.usleep(sleep)
  end
  hs.mouse.absolutePosition({x = math.floor(x2), y = math.floor(y2)})
end

----------------------------------------------------------------------------------------------
--[[ stuff to play with later
hs.tabs.enableForApp("Teams") - https://www.hammerspoon.org/docs/hs.tabs.html
]]--

----------------------------------------------------------------------------------------------
--[[ basement - storage and other references
-- 2026-07-06 - removed from hyper-L and kept here for future reference
--  if frontmost_app_title:match("Slack") then
--    hs.eventtap.keyStroke({"shift", "cmd"}, "u")
--    hs.eventtap.keyStrokes(tag)
--    hs.eventtap.keyStroke({}, "tab")
--    hs.eventtap.keyStrokes(mypasteboard)
--    hs.eventtap.keyStroke({}, "return")
-------------
also removed from hyper-L, another way to do the Notion/Slack paste, but clumsier and with a race condition on the paste
--    local hold_url = mypasteboard
--    hs.pasteboard.writeDataForUTI(nil, "public.html",
--        ('<a href="%s">%s</a>'):format(mypasteboard, tag))
--    hs.eventtap.keyStroke({"cmd"}, "v")
--    hs.pasteboard.setContents(hold_url)
--    hs.eventtap.keyStroke({},"escape")
]]--
