require 'bundler'
require 'date'
Bundler.require
Dotenv.load

require_relative '../lib/get_db'
require_relative '../lib/date_wday_jp'

rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.access_token = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

info_date = Date.today + 1
info = QKbot::Day.new(info_date)

tweet = "#{info_date.month}月#{info_date.day}日 #{info_date.wday_jp}曜日"
unless info.event == "" then
  tweet << " <#{info.event}>"
end
tweet << "\n"
if (str = info.to_s) == "" then
  tweet << " 休講情報はありません。\n"
else
  tweet << str + "\n"
  tweet << "#{info.url}"
end

tweet << "\n※情報は不正確な可能性があります。"
rest_client.update(tweet)
puts "send tweet!"