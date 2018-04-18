#!/bin/sh

#Run from 20 o'clock Sunday to Thursday
conf='0 20 * * 0-4 '$(dirname $(readlink -f $0))$"/startbot.sh"
crontab $conf
