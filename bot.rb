require 'bundler'
require 'logger'
Bundler.require
Dotenv.load

require_relative 'lib/daemonize'
require_relative 'lib/discord/commandbot'
require_relative 'lib/logger'

logger = QKbot::Logger.new(ENV['WEBHOOKS_URL'])

bot_daemon = QKbot::Daemon.new("./bot.pid", logger) do
  QKbot::Discord.commandbot(Logger.new("./QKbot.log"), ENV)
end

bot_daemon.run