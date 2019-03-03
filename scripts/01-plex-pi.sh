#!/bin/bash

ssh plex-pi <<endssh
sudo echo "$(date '+%Y-%m-%d %H:%M:%S') - Powering down now!" >> /root/off-switch.log
sudo poweroff
exit
endssh
