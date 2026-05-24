module Pal
  module Commands
    class StopCommand
      NAME = :stop
      DESCRIPTION = "Hentikan audio yang sedang diputar PAL.".freeze

      def initialize(bot:, config:, voice_registry:)
        @bot = bot
        @config = config
        @voice_registry = voice_registry
      end

      def register
        @bot.register_application_command(NAME, DESCRIPTION, server_id: @config.guild_id)

        @bot.application_command(NAME) do |event|
          connection = @voice_registry.fetch(guild_key(event))
          unless connection
            event.respond(content: "PAL belum tersambung ke voice channel di server ini.")
            next
          end

          connection.stop_playing if connection.respond_to?(:stop_playing)
          event.respond(content: "Playback PAL sudah dihentikan.")
        rescue StandardError => error
          warn "Failed to handle /stop: #{error.class}: #{error.message}"
          event.respond(content: "Maaf, PAL gagal menghentikan playback.")
        end
      end

      private

      def guild_key(event)
        if event.respond_to?(:server) && event.server
          event.server.id
        else
          event.channel.id
        end
      end
    end
  end
end
