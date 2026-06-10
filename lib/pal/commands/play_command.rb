# frozen_string_literal: true

require "pal/audio_source_resolver"
require "pal/queue_registry"
require "pal/commands/command_helpers"

module Pal
  module Commands
    class PlayCommand
      include CommandHelpers

      NAME = :play
      DESCRIPTION = "Putar audio dari URL YouTube."
      URL_OPTION = "url"
      ERROR_MESSAGE = "Maaf, PAL gagal memproses perintah ini."

      def initialize(bot:, config:, voice_registry:, queue_registry:, audio_source_resolver: AudioSourceResolver.new)
        @bot = bot
        @config = config
        @voice_registry = voice_registry
        @queue_registry = queue_registry
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
        key = guild_key(event)
        result = @queue_registry.enqueue(key, QueueRegistry::Track.new(url: url, channel: event.channel))

        if result[:position] > 1
          event.respond(content: "Audio masuk antrean posisi #{result[:position]}.")
        else
          event.respond(content: "PAL sedang menyiapkan audio dari YouTube.")
        end

        Thread.new { drain_queue(key, voice_channel, event.channel) } if result[:should_start]
      end

      def drain_queue(key, voice_channel, notify_channel)
        connection = @voice_registry.fetch_or_register(key) { @bot.voice_connect(voice_channel) }

        while (track = @queue_registry.dequeue(key))
          play_track(connection, track)
        end
      rescue StandardError => error
        warn "Queue drain failed: #{error.class}: #{error.message}"
        notify_channel.send_message("PAL gagal memutar audio: #{error.message}")
        @queue_registry.reset(key)
      end

      def play_track(connection, track)
        audio_url = @audio_source_resolver.resolve(track.url)
        connection.play_file(audio_url)
      rescue AudioSourceResolver::Error => error
        warn "Failed to resolve audio: #{error.class}: #{error.message}"
        track.channel.send_message("PAL gagal memutar audio: #{error.message}")
      rescue StandardError => error
        warn "Unexpected playback error: #{error.class}: #{error.message}"
        track.channel.send_message("PAL gagal memutar audio: terjadi kesalahan tak terduga.")
      end
    end
  end
end
