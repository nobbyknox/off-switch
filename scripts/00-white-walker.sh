#!/bin/bash

ssh white-walker <<endssh
echo "$(date '+%Y-%m-%d %H:%M:%S') - Powering down now!" >> /tmp/off-switch.log
poweroff
exit
endssh
