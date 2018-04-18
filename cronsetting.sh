#!/bin/sh
tmpdir=$(mktemp temp_XXXXXX)
# Command to be executed last
trap "rm -f $tmpdir" 0 1 2 3 15

# Run from 20 o'clock Sunday to Thursday
echo "0 20 * * 0-4 $(dirname $(readlink -f $0))/run_noticebot.sh" > $tmpdir
crontab $tmpdir
