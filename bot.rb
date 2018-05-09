require 'bundler'
require 'logger'
Bundler.require
Dotenv.load

require_relative 'lib/daemonize'
require_relative 'lib/discord/commandbot'

# create log folder
if Dir["log"].empty?
  Dir.mkdir "log"
end
logger = Logger.new("./log/bot.log")

bot_daemon = QKbot::Daemon.new("./bot.pid", logger) do
  QKbot::Discord.commandbot(Logger.new("./QKbot.log"), ENV)
end

bot_daemon.run