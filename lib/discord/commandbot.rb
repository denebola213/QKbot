module QKbot
  module Discord
    def self.commandbot(logger, env)

      discord_commandbot = Discordrb::Commands::CommandBot.new(
        token: env["DISCORD_TOKEN"],
        client_id: env["DISCORD_CLIENT_ID"],
        prefix: env["DISCORD_PREFIX"])

      # set root user
      discord_commandbot.ready do |event|
        discord_commandbot.set_user_permission(env["DISCORD_ROOTUSER_ID"].to_i, 5)
        logger.info('start discord command bot!')
      end

      # ping test
      discord_commandbot.command(:ping) do |event|
        pong_message = event.send_message("pong")
        pong_message.edit("pong #{(pong_message.timestamp - event.message.timestamp) * 1000}ms")
      end

      # --- root only command ---
      
      # BOTが導入されているサーバーの名前
      discord_commandbot.command(:addservers, permission_level: 5, help_available: false) do |event|
        discord_commandbot.servers.each_value do |server|
          event << server.name
        end
        event << ''
      end

      # running commandbot
      discord_commandbot.run(:async)
    end
  end
end