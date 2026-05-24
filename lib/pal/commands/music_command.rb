module Pal
  module Commands
    class MusicCommand
      NAME = :musik
      DESCRIPTION = "Kontrol fitur musik PAL.".freeze
      OPTION_NAME = "aksi".freeze
      DEFAULT_ACTION = "gabung".freeze
      ERROR_MESSAGE = "Maaf, PAL gagal menjalankan perintah musik.".freeze

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

      def option_value(event, name)
        return nil unless event.respond_to?(:options)

        option = event.options[name] || event.options[name.to_sym]
        option.respond_to?(:value) ? option.value : option
      end

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

        event.respond(content: "PAL sedang mencoba masuk ke #{voice_channel.name}.")

        Thread.new do
          connection = @bot.voice_connect(voice_channel)
          @voice_registry.register(guild_key(event), connection)
        rescue StandardError => error
          warn "Failed to join voice channel: #{error.class}: #{error.message}"
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
