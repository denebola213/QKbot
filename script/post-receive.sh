#!/bin/sh

cd $(dirname $(readlink -f $0))
cd ../

bundle install --path vendor/bundler > ./log/bundle.log

# logディレクトリがなければ作る
if test ! -d 'log' ;then
  mkdir 'log'
fi

#Shell Script のパーミッション変更
chmod -R 755 script

/bin/sh ./script/cronsetting.sh
#/bin/sh ./script/restart_commandbot.sh
