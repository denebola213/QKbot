#!/bin/sh

cd $(dirname $(readlink -f $0))
cd ../

bundle install --path vendor/bundle > ./log/bundle.log

# logディレクトリがなければ作る
if test ! -d 'log' ;then
  mkdir 'log'
fi

/bin/sh ./script/cronsetting.sh
#/bin/sh ./script/restart_commandbot.sh
