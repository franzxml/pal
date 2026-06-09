# frozen_string_literal: true

require "pal/commands/command_helpers"

module Pal
  module Commands
    class MusicCommand
      include CommandHelpers

      NAME = :musik
      DESCRIPTION = "Kontrol fitur musik PAL."
      OPTION_NAME = "aksi"
      DEFAULT_ACTION = "gabung"
      ERROR_MESSAGE = "Maaf, PAL gagal menjalankan perintah musik."

      ACTIONS = {
        "gabung" => "Masuk ke voice channel kamu.",
        "keluar" => "Keluar dari voice channel.",
        "status" => "Cek status koneksi musik."
      }.freeze

      ACTION_CHOICES = ACTIONS.keys.to_h { |action| [action, action] }.freeze

      def initialize(bot:, config:, voice_registry:)
        @bot = bot
        @config = config
        @voice_registry = voice_registry
      end

      def register
        @bot.register_application_command(NAME, DESCRIPTION, server_id: @config.guild_id) do |command|
          command.string(
            OPTION_NAME,
            "Pilih aksi musik.",
            required: false,
            choices: ACTION_CHOICES
          )
        end

        @bot.application_command(NAME) do |event|
          handle(event, action_from(event))
        rescue StandardError => error
          warn "Failed to handle /musik: #{error.class}: #{error.message}"
          event.respond(content: ERROR_MESSAGE)
        end
      end

      def action_from(event)
        value = option_value(event, OPTION_NAME)
        ACTIONS.key?(value) ? value : DEFAULT_ACTION
      end

      private

      def handle(event, action)
        case action
        when "gabung"
          join_voice_channel(event)
        when "keluar"
          leave_voice_channel(event)
        when "status"
          music_status(event)
        else
          event.respond(content: "Aksi musik tidak dikenal. Pilih: #{ACTIONS.keys.join(', ')}.")
        end
      end

      def join_voice_channel(event)
        voice_channel = event.user.voice_channel
        unless voice_channel
          event.respond(content: "Masuk ke voice channel dulu, lalu jalankan `/musik gabung` lagi.")
          return
        end

        if @voice_registry.connected?(guild_key(event))
          event.respond(content: "PAL sudah tersambung ke voice channel. Jalankan `/musik keluar` dulu untuk pindah.")
          return
        end

        event.respond(content: "PAL sedang mencoba masuk ke #{voice_channel.name}.")

        Thread.new do
          @voice_registry.fetch_or_register(guild_key(event)) { @bot.voice_connect(voice_channel) }
        rescue StandardError => error
          warn "Failed to join voice channel: #{error.class}: #{error.message}"
          event.channel.send_message("PAL gagal masuk ke voice channel: #{error.message}")
        end
      end

      def leave_voice_channel(event)
        connection = @voice_registry.delete(guild_key(event))
        unless connection
          event.respond(content: "PAL belum tersambung ke voice channel di server ini.")
          return
        end

        connection.destroy if connection.respond_to?(:destroy)
        event.respond(content: "PAL sudah keluar dari voice channel.")
      end

      def music_status(event)
        if @voice_registry.connected?(guild_key(event))
          event.respond(content: "PAL sedang tersambung ke voice channel.")
        else
          event.respond(content: "PAL belum tersambung ke voice channel. Jalankan `/musik gabung` dari voice channel.")
        end
      end
    end
  end
end
