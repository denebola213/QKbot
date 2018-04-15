module QKbot
  module Twitter

    def self.tweet_info date
      rest_client = ::Twitter::REST::Client.new do |config|
        config.consumer_key = ENV["CONSUMER_KEY"]
        config.consumer_secret = ENV["CONSUMER_SECRET"]
        config.access_token = ENV["ACCESS_TOKEN"]
        config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
      end

      # 土曜,日曜は通知しない
      if 0 < date.wday && date.wday < 6
        info_day = DB::Day.new(date)
      
        tweet = TweetString.new "#{date.month}月#{date.day}日 #{date.wday_jp}曜日"
        unless info_day.event == "" then
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
      
        LOG.info("tweet now! #{before_tweet.uri.to_s}")
      else
        LOG.warn("This bot don't tweet saturday and sunday")
      end
    end
    
  end
end