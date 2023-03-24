set theResponse to display dialog "date and time: d,dd,h,hh,dh,ddhh" default answer ""
if ((text returned of theResponse) = "dd") then
    do shell script "/bin/date +%Y-%m-%d"
else if ((text returned of theResponse) = "d") then
    do shell script "/bin/date +%Y%m%d"
else if ((text returned of theResponse) = "hh") then
    do shell script "/bin/date +%H:%M"
else if ((text returned of theResponse) = "h") then
    do shell script "/bin/date +%H%M"
else if ((text returned of theResponse) = "dh") then
    do shell script "/bin/date +%Y%m%d.%H%M"
else if ((text returned of theResponse) = "ddhh") then
    do shell script "/bin/date +%Y-%m-%d.%H:%M"
else
    display dialog "WTF is this: -> " & (text returned of theResponse)
end if

