require "pal/audio_source_resolver"

module Pal
  module Commands
    class PlayCommand
      NAME = :play
      DESCRIPTION = "Putar audio dari URL YouTube.".freeze
      URL_OPTION = "url".freeze
      ERROR_MESSAGE = "Maaf, PAL gagal memutar audio dari URL itu.".freeze

      def initialize(bot:, config:, voice_registry:, audio_source_resolver: AudioSourceResolver.new)
        @bot = bot
        @config = config
        @voice_registry = voice_registry
        @audio_source_resolver = audio_source_resolver
      end

      def register
        @bot.register_application_command(NAME, DESCRIPTION, server_id: @config.guild_id) do |command|
          command.string(URL_OPTION, "URL YouTube yang ingin diputar.", required: true)
        end

        @bot.application_command(NAME) do |event|
          handle(event)
        rescue StandardError => error
          warn "Failed to handle /play: #{error.class}: #{error.message}"
          event.respond(content: ERROR_MESSAGE)
        end
      end

      private

      def handle(event)
        voice_channel = event.user.voice_channel
        unless voice_channel
          event.respond(content: "Masuk ke voice channel dulu, lalu jalankan `/play` lagi.")
          return
        end

        url = option_value(event, URL_OPTION)
        event.respond(content: "PAL sedang menyiapkan audio dari YouTube.")

        Thread.new do
          connection = connection_for(event, voice_channel)
          audio_url = @audio_source_resolver.resolve(url)
          connection.play_file(audio_url)
        rescue StandardError => error
          warn "Failed to play YouTube audio: #{error.class}: #{error.message}"
        end
      end

      def connection_for(event, voice_channel)
        guild_id = guild_key(event)
        connection = @voice_registry.fetch(guild_id)
        return connection if connection

        connection = @bot.voice_connect(voice_channel)
        @voice_registry.register(guild_id, connection)
        connection
      end

      def option_value(event, name)
        option = event.options[name] || event.options[name.to_sym]
        option.respond_to?(:value) ? option.value : option
      end

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
