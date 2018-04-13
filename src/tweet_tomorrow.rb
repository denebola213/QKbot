require 'bundler'
require 'date'
Bundler.require
Dotenv.load

require_relative '../lib/Info'
require_relative '../lib/date_wday_jp'
require_relative '../lib/TweetString'

rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.access_token = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

info_date = Date.today + 1
# 金曜,土曜は通知しない
if info_date.wday < 5
  info_day = QKbot::Day.new(info_date)

  tweet = QKbot::TweetString.new "#{info_date.month}月#{info_date.day}日 #{info_date.wday_jp}曜日"
  if info_day.event then
    tweet << " <#{info_day.event}>"
  end
  tweet << "\n"

  if (str = info_day.to_s) == "" then
    tweet << " 休講情報はありません。\n"
  else
    tweet << str + "\n"
    tweet << "#{info_day.url}"
  end

  tweet << "\n※情報は不正確な可能性があります。"

  before_tweet = nil
  tweet.parse.each do |str|
    if before_tweet == nil then
      before_tweet = rest_client.update(str)
    else
      before_tweet = rest_client.update(str, in_reply_to_status_id: before_tweet.id)
    end
  end
end