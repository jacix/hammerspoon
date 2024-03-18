# hammerspoon
Jason's public hammerspoon scripts - last updated 2024-03-18

### ```init.lua``` - the initializer with general stuff for any environment
#### ```recursives.lua``` - create recursive hotkey for typing the date, time, date+time in long or short formats

### hotkeys and other functions
* demos from the HS intro, many of which are now in the basement
* ```ctrl```-```opt```-```cmd```-```C``` => show a clock (via spoon.AClock)
* ```ctrl```-```opt```-```cmd```-```F``` => show foreground application, mouse location, focused application, etc
* ```ctrl```-```opt```-```cmd```-```H``` => show active hotkeys
* ```ctrl```-```opt```-```cmd```-```R``` => reload config (via spoon.ReloadConfiguration)
* ```ctrl```-```opt```-```cmd```-```S``` => show whether sleep is enabled
* ```ctrl```-```opt```-```cmd```-```V``` => Show clipboard manager (via ClipboardTool)
* ```ctrl```-```opt```-```cmd```-```/``` => show app-specific cheat sheet (via spoon.KSheet)
* ```ctrl```-```opt```-```cmd```-```shift```-```M``` => draw a circle around the mouse
* ```opt```-```space``` => use RecursiveBinder to load date/time submenu
* ```opt```-```cmd```-```V``` => Bypass paste-blocking
* create menubar item to enable/disable sleep
* bind URLS ```hammerspoon://{stayup|chill}``` for other apps to call
* At the end is a toggle to decide whether to load location-specific files

#### Spoons
* ClipboardTool - clipboard manager
* FadeLogo - fades the logo after reload
* KSheet - cheat sheet
* Keychain - interact with Apple Keychain
* MicMute - mute the mic
* RecursiveBinder - bind recursive hotkeys (e.g.: hyper-D then dd to print the date, hyper-D hh for hour:min, etc)
* ReloadConfiguration - duh
* SpoonInstalll - simplified spoon installer and manager
* URLDispatcher - pick which browser opens specific URLs

---

## ```hometools.lua``` - Things applicable only for home
  * Disabled for now - everything moved to music-webserver.lua
---

## ```worktools.lua``` - Things applicable only for work
  * ```ctrl```-```opt```-```cmd```-```J``` => print my work email address
  * ```ctrl```-```opt```-```cmd```-```L``` => take a URL from the pasteboard and create a prettified hyperlink in Teams, Confluence, Jira, Outlook
  * ```ctrl```-```opt```-```cmd```-```M``` => mute the mic at the OS level
  * URL bindings to start and stop VPNs
  * URL bindings for Teams: mute mic and camera, hang up, raise hand, 
  * URLDispatcher opens specific URLs in Firefox

---

## ```music-webserver.lua``` - Basic, dumb web server to manage Apple Music
  * URL calls to play, pause, change volume, get artist or track or album. Work-in-progress.

---

### ```toggle-notification.lua``` - Simple script to toggle app notifications in system settings
  * Why? Dozens of applications had been enabled to send notifications. Clearing them manually was irritating and time consuming - and very automation-friendly.  I probably won't have to use this again, but it was helpful and fun.
