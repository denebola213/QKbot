require_relative '../db/info'
require_relative '../date_wday_jp'

module QKbot
  module Discord
    def self.post_info(date, logger, env)
      discord_bot = Discordrb::Bot.new(
        token: env["DISCORD_TOKEN"],
        client_id: env["DISCORD_CLIENT_ID"])

      discord_bot.run :async

      # default channel を探す
      channels = Array.new
      discord_bot.servers.each_value do |server|
        channels << server.text_channels[0]
      end
      
      # 土曜,日曜は通知しない
      if 0 < date.wday && date.wday < 6
        info_day = DB::Day.new(date)

        channels.each do |channel|
          #nil
          next unless channel

          channel.send_embed do |embed|
            embed.title = "#{date.month}月#{date.day}日 #{date.wday_jp}曜日"
            unless info_day.event == "" then
              embed.title << " <#{info_day.event}>"
            end
            embed.url = info_day.url
            embed.description = info_day.to_s
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '※情報は不正確な可能性があります。', icon_url: nil)
          end
        end

        logger.info("post message to discord now!")
      else
        logger.warn("This bot don't post message saturday and sunday")
      end

    end
  end
end
