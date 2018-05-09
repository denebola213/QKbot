require 'bundler'
require 'logger'
Bundler.require
Dotenv.load

require_relative 'lib/daemonize'
require_relative 'lib/db/crawle'
require_relative 'lib/twitter/tweet_info'
require_relative 'lib/discord/post_info'

module QKbot
  class Logger
    def initialize(&bot)
      @bot_handler = bot
    end

    def debug(message)
      @bot_handler.call("<#{Time.now.to_s}> [DEBUG] : " + message)
    end
    
    def info(message)
      @bot_handler.call("<#{Time.now.to_s}> [INFO] : " + message)
    end

    def warn(message)
      @bot_handler.call("<#{Time.now.to_s}> [WARN] : " + message)
    end

    def error(message)
      @bot_handler.call("<#{Time.now.to_s}> [ERROR] : " + message)
    end

    def fatal(message)
      @bot_handler.call("<#{Time.now.to_s}> [FATAL] : " + message)
    end

  end
end

logger = QKbot::Logger.new do |message|
  webhook_url = URI.parse(ENV['WEBHOOKS_URL']) 
  Net::HTTP.post_form(webhook_url, {'content' => message})
end

notify_daemon = QKbot::Daemon.new("./notify.pid", logger, true) do

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