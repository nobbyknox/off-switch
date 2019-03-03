#!/bin/bash

ssh plex-pi <<endssh
echo "$(date '+%Y-%m-%d %H:%M:%S') - Powering down now!" >> /root/off-switch.log
poweroff
exit
endssh
