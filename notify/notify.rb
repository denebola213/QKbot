require 'bundler'
Bundler.require
Dotenv.load

require_relative 'lib/db/crawle'
require_relative 'lib/twitter/tweet_info'
require_relative 'lib/discord/post_info'
require_relative 'lib/logger'

logger = QKbot::Logger.new(ENV['WEBHOOKS_URL'])
logger.info "start QK Notify Bot!"

flag = false

loop do
  QKbot::DB.crawle(logger)
  nowtime = Time.now
  # UST 11:00, JST 20:00
  if nowtime.hour == (20 - 9) && (0..4) === nowtime.wday then
    unless flag
      tomorrow = Date.today + 1
      QKbot::Twitter.tweet_info(tomorrow, logger, ENV)
      QKbot::Discord.post_info(tomorrow, logger, ENV)
      flag = true
    end
  else
    flag = false
  end
  sleep(60)
end