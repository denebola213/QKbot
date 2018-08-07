require 'bundler'
Bundler.require
Dotenv.load(File.expand_path('../.env', File.dirname(File.expand_path(__FILE__))))

require_relative 'commandbot'
require_relative 'logger'

logger = QKbot::Logger.new(ENV['WEBHOOKS_URL'])


QKbot::Discord.commandbot(logger, ENV)
