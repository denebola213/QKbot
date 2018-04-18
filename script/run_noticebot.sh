#!/bin/sh

cd $(dirname $(readlink -f $0))
cd ../


`which ruby` noticebot.rb >> ./log/cron.log 2>> ./log/cron_err.log
