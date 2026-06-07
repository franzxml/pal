# frozen_string_literal: true

require "pal/commands/command_helpers"

module Pal
  module Commands
    class StopCommand
      include CommandHelpers

      NAME = :stop
      DESCRIPTION = "Hentikan audio yang sedang diputar PAL."

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
    end
  end
end
