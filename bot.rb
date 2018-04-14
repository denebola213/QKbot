require 'bundler'
require 'date'
require 'open-uri'
Bundler.require
Dotenv.load

module QKbot
  class Lib
    def self.load
      Dir[File.dirname(__FILE__) + '/lib/*.rb'].each do |file|
        require_relative file
      end
    end
  end

  LOG = Logger.new('QKbot.log')
end

QKbot::Lib.load

require_relative 'src/get_web'
require_relative 'src/tweet_tomorrow'