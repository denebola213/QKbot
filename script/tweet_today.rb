require 'bundler'
require 'date'
Bundler.require
Dotenv.load

require_relative './script/get_db'

rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.access_token = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end
info_date = Date.today
info = QKbot::Day.new(info_date)

tweet = "#{info_date.month}月#{info_date.day}日 "
case info_date.wday
when 0 then
  tweet << "日曜日"
when 1 then
  tweet << "月曜日"
when 2 then
  tweet << "火曜日"
when 3 then
  tweet << "水曜日"
when 4 then
  tweet << "木曜日"
when 5 then
  tweet << "金曜日"
when 6 then
  tweet << "土曜日"
end

if info.event then
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