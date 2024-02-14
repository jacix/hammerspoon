# hammerspoon
Jason's public hammerspoon scripts - last updated 2023-03-25

### ```init.lua``` - the initializer with general stuff for any environment
#### hotkeys and other functions
* demos from the HS intro, many of which are now in the basement
* ```cmd```-```opt```-```D``` => launch applescript to ask for desired date pattern: dd, ddd, hh, hhh, ddhh, dddhhh
* ```ctrl```-```opt```-```cmd```-```C``` => show a clock (via spoon.AClock)
* ```ctrl```-```opt```-```cmd```-```F``` => show foreground application
* ```ctrl```-```opt```-```cmd```-```H``` => show active hotkeys
* ```ctrl```-```opt```-```cmd```-```R``` => reload config (via spoon.ReloadConfiguration)
* ```ctrl```-```opt```-```cmd```-```V``` => Show clipboard manager (via ClipboardTool)
* ```ctrl```-```opt```-```cmd```-```/``` => show app-specific cheat sheet (via spoon.KSheet)
* create menubar item to enable/disable sleep
  * bind URLS ```hammerspoon://{stayup|chill}``` for other apps to call
  * ```ctrl```-```opt```-```cmd```-```S``` will report sleep status
* At the end is a toggle to decide whether to load worktools.lua

#### Spoons
* ClipboardTool - clipboard manager
* FadeLogo - fades the logo after reload
* HammerText - unofficial, from [Max Anderson](https://gist.github.com/maxandersen/d09ebef333b0c7b7f947420e2a7bbbf5)'s gist on github. Creates multi-key triggers, like
  * ```ddd.``` -> print the current date with dashes (e.g.: 2023-03-25)
  * ```dd.``` -> print the current date without dashes (e.g.: 20230325)
  * ```hhh.``` -> print the current time with a colon (e.g.: 11:31)
  * ```hh.``` -> print the current time without a colon (e.g.: 1131)
  * ```ddhh.``` -> print the current date+time (e.g.: 20230325.1131)
  * ```awsus.``` -> aws2.teladoc.com
  * ```awsca.``` -> aws.teladoc.ca
  * ```awsdk.``` -> aws.teladoc.dk
* KSheet - cheat sheet
* ReloadConfiguration - duh
* SpoonInstalll - simplified spoon installer and manager

---

## ```worktools.lua``` - things applicable only for work
  * ```ctrl```-```opt```-```cmd```-```T``` => take a URL from the pasteboard and create a prettified hyperlink in Teams
  * ```ctrl```-```opt```-```cmd```-```J``` => print my work email address

## ```music-webserver.lua``` - basic, dumb web server to manage Apple Music
  * various URL calls to play, pause, change volume, get artist or track or album. WIP
