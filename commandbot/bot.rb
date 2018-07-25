require 'bundler'
Bundler.require
Dotenv.load

require_relative 'commandbot'
require_relative 'logger'

logger = QKbot::Logger.new(ENV['WEBHOOKS_URL'])


QKbot::Discord.commandbot(logger, ENV)
