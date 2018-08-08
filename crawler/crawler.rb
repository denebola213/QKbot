require 'bundler'
Bundler.require
Dotenv.load

require_relative 'crawle'
require_relative 'logger'

logger = QKbot::Logger.new(ENV['WEBHOOKS_URL'])
logger.info "start QK Crawler!"

loop do
  QKbot::DB.crawle(logger)
  sleep(60)
end