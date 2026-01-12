#!/usr/bin/osascript
(* 
If clipboard has an image, open preview and create a new file with it
Change log:
* 2026-01-12 - initial creation from what was a shortcut
*)

on run
    set imgOK to clipboardHasImage()
    if imgOK is false then
        return "No image found in the clipboard."
    end if
    
    -- Open Preview and paste into a new document (UI scripting)
    tell application "Preview" to activate
    delay 0.2
    
    tell application "System Events"
        keystroke "n" using {command down} -- New from clipboard (or new doc)
    end tell
    
    return "Opened " & imgOK & " in Preview."
end run

on clipboardHasImage()
    -- Prefer type coercion checks (works even if clipboard info is inconsistent)
    -- Try common image flavors
    try
        set _ to (the clipboard as TIFF picture)
        return "tiff"
    end try
    
    try
        set _ to (the clipboard as «class PNGf»)
        return "png"
    end try
    
    try
        set _ to (the clipboard as JPEG picture)
        return "jpg"
    end try
    
    -- Some apps put images on the clipboard as a "picture"
    try
        set _ to (the clipboard as picture)
        return "picture"
    end try
    
    -- Fallback: check clipboard UTI list
    try
        set tList to clipboard info
        set utiList to {}
        repeat with t in tList
            set end of utiList to (t as text)
        end repeat
        
        set imageUTIs to {"public.tiff", "public.png", "public.jpeg", "public.heic", "com.compuserve.gif", "public.bmp"}
        repeat with u in imageUTIs
            if utiList contains (u as text) then return "other"
        end repeat
    end try
    
    return false
end clipboardHasImage
