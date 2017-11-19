module QKbot
  require 'bundler'
  Bundler.require
  Dotenv.load

  #DBを開く
  DB = SQLite3::Database.new('./data/info.db')
  #hashで受け取る
  DB.results_as_hash = true
  
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV["CONSUMER_KEY"]
    config.consumer_secret = ENV["CONSUMER_SECRET"]
    config.access_token = ENV["ACCESS_TOKEN"]
    config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
  end



end