module QKbot
  require 'bundler'
  require 'date'
  Bundler.require
  Dotenv.load

  #my class
  require_relative 'get_db'
  
  #twitter bot 起動
  client = Twitter::Streaming::Client.new do |config|
    config.consumer_key = ENV["CONSUMER_KEY"]
    config.consumer_secret = ENV["CONSUMER_SECRET"]
    config.access_token = ENV["ACCESS_TOKEN"]
    config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
  end
  rest_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV["CONSUMER_KEY"]
    config.consumer_secret = ENV["CONSUMER_SECRET"]
    config.access_token = ENV["ACCESS_TOKEN"]
    config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
  end

  puts 'OK'
  client.user do |object|
    if object.is_a?(Twitter::DirectMessage) then
      target_date = Date.parse(object.text)

      day = QKbot::Day.new(target_date)
      message = "- " + target_date.strftime("%m月%d日") + "の休講情報 -"
      day.info.each do |info|
        message << "\n"

        #情報の種類
        message << "【" + info.type.join(', ') + "】"
        #学年
        if info.grade <= 5 then
          message << info.grade.to_s
        elsif info.grade == 6 then
          message << "専1"
        elsif info.grade == 7 then
          message << "専2"
        end
        #学科
        if info.department != "" then
          message << info.department.join(',')
        end
        #組
        if info.num != 0 then
          message << "-" + info.num.to_s
        end
        #教科名
        if info.name.is_a?(String) then
          message << " " + info.name
        else
          message << " " + info.name[:before] + " => " + info.name[:after]
        end
      end
      rest_client.create_direct_message(object.sender, message)
    end
  end
end