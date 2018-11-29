require 'bundler'
require 'date'
require 'open-uri'
Bundler.require
Dotenv.load(File.expand_path('../.env', File.dirname(File.expand_path(__FILE__))))

require_relative 'lib/db/crawle'
require_relative 'lib/twitter/tweet_info'
require_relative 'lib/discord/post_info'
require_relative 'lib/logger'

logger = Logger.new(STDOUT)

QKbot::DB.crawle(logger)

today = Date.today
QKbot::Twitter.tweet_info(today, logger, ENV)
QKbot::Discord.post_allserver(today, logger, ENV)
