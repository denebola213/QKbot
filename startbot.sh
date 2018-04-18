#!/bin/sh

cd $(dirname $(readlink -f $0))

# logディレクトリがなければ作る
if test ! -d 'log' ;then
  mkdir 'log'
fi

chmod 755 bot.rb
`which ruby` bot.rb >> ./log/cron.log 2>> ./log/cron_err.log
