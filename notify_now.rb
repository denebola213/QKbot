require 'bundler'
require 'date'
require 'open-uri'
Bundler.require
Dotenv.load

module QKbot
  def self.load file, foldername
    Dir[File.dirname(file) + "/#{foldername}/*.rb"].each do |file|
      require_relative file
    end
  end
end
logger = Logger.new(STDOUT)
QKbot.load(__FILE__, "lib")

QKbot::DB.crawle

today = Date.today
QKbot::Twitter.tweet_info(today, logger, ENV)
QKbot::Discord.post_info(today, logger, ENV)
