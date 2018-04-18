module QKbot
  module Discord
    def self.commandbot
      discord_commandbot = Discordrb::Commands::CommandBot.new(
        token: ENV["DISCORD_TOKEN"],
        client_id: ENV["DISCORD_CLIENT_ID"],
        prefix: ENV["DISCORD_PREFIX"])

      # set root user
      discord_commandbot.ready do |event|
        discord_commandbot.set_user_permission(ENV["DISCORD_ROOTUSERID"].to_i, 5)
        LOG.info('start discord command bot!')
      end

      # BOTが導入されているサーバーの名前
      discord_commandbot.command(:addservers, permission_level: 5, help_available: false) do |event|
        discord_commandbot.servers.each_value do |server|
          event << server.name
        end
        event << ''
      end

      # ping test
      discord_commandbot.command(:ping, permission_level: 5, help_available: false) do |event|
        event << "pong"
      end

      # stop command bot
      discord_commandbot.command(:stop, permission_level: 5, help_available: false) do |event|
        LOG.info('stop discord command bot.')
        discord_commandbot.stop
      end

      discord_commandbot.run
    end
  end
end