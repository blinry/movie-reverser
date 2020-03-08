#!/bin/sh

ffmpeg -i atypicals01e01.mkv -f segment -segment_time 00:01:00 -c copy -map 0 -reset_timestamps 1 output%03d.mkv

for file in output*; do
    ffmpeg -y -i $file -codec:v libx264 -preset medium -vf reverse -af areverse rev$file.mkv
done

printf "file '%s'\n" revoutput* | tac > list.txt

ffmpeg -y -f concat -safe 0 -i list.txt -c copy reverse.mkv
