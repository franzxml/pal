# frozen_string_literal: true

require "pal/commands/command_helpers"

module Pal
  module Commands
    class StopCommand
      include CommandHelpers

      NAME = :stop
      DESCRIPTION = "Hentikan audio yang sedang diputar PAL."
      ERROR_MESSAGE = "Maaf, PAL gagal menghentikan playback."

      def initialize(bot:, config:, voice_registry:, queue_registry:)
        @bot = bot
        @config = config
        @voice_registry = voice_registry
        @queue_registry = queue_registry
      end

      def register
        @bot.register_application_command(NAME, DESCRIPTION, server_id: @config.guild_id)

        @bot.application_command(NAME) do |event|
          handle(event)
        rescue StandardError => error
          warn "Failed to handle /stop: #{error.class}: #{error.message}"
          event.respond(content: ERROR_MESSAGE)
        end
      end

      private

      def handle(event)
        key = guild_key(event)
        connection = @voice_registry.fetch(key)

        unless connection
          event.respond(content: "PAL belum tersambung ke voice channel di server ini.")
          return
        end

        @queue_registry.clear(key)
        connection.stop_playing if connection.respond_to?(:stop_playing)
        event.respond(content: "Playback PAL sudah dihentikan dan antrean dikosongkan.")
      end
    end
  end
end
