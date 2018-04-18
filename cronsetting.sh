#!/bin/sh

#日曜から木曜の20時
conf='0 20 * * 0-4 '$(dirname $(readlink -f $0))$"/startbot.sh"
crontab $conf