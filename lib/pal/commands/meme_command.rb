# frozen_string_literal: true

require "pal/meme_catalog"
require "pal/commands/command_helpers"

module Pal
  module Commands
    class MemeCommand
      include CommandHelpers

      NAME = :meme
      DESCRIPTION = "Kirim meme acak ke kanal ini."
      ERROR_MESSAGE = "Maaf, PAL gagal mengambil meme sekarang."

      def initialize(bot:, config:, meme_catalog: MemeCatalog)
        @bot = bot
        @config = config
        @meme_catalog = meme_catalog
      end

      def register
        @bot.register_application_command(NAME, DESCRIPTION, server_id: @config.guild_id)

        @bot.application_command(NAME) do |event|
          event.respond(content: @meme_catalog.random)
        rescue StandardError => error
          warn "Failed to handle /meme: #{error.class}: #{error.message}"
          event.respond(content: ERROR_MESSAGE)
        end
      end
    end
  end
end
