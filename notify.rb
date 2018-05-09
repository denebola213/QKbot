require 'bundler'
require 'logger'
Bundler.require
Dotenv.load

require_relative 'lib/daemonize'
require_relative 'lib/db/crawle'
require_relative 'lib/twitter/tweet_info'
require_relative 'lib/discord/post_info'
require_relative 'lib/logger'

logger = QKbot::Logger.new(ENV['WEBHOOKS_URL'])

notify_daemon = QKbot::Daemon.new("./notify.pid", logger, 'QK notify bot', true) do

  flag = false

  loop do
    sleep(10)
    QKbot::DB.crawle
    nowtime = Time.now
    if nowtime.hour == 20 && (0..4) === nowtime.wday then
      unless flag
        tomorrow = Date.today + 1
        QKbot::Twitter.tweet_info(tomorrow, logger, ENV)
        QKbot::Discord.post_info(tomorrow, logger, ENV)
        flag = true
      end
    else
      flag = false
    end

    # interrupt process
    if notify_daemon.flag_int
      break
    end
  end
end

notify_daemon.run