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

  LOG = Logger.new('./log/QKbot.log')
end

QKbot.load(__FILE__, "lib")

QKbot::DB.crawle

tomorrow = Date.today + 1
QKbot::Twitter.tweet_info(tomorrow)
QKbot::Discord.post_info(tomorrow)
