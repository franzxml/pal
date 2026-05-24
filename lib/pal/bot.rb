require "discordrb"

require "pal/commands"
require "pal/config"
require "pal/voice_registry"

module Pal
  class Bot
    def initialize(config: Config.from_env)
      @config = config
      @bot = Discordrb::Bot.new(token: config.token, client_id: config.client_id)
      @voice_registry = VoiceRegistry.new
    end

    def run
      register_commands
      @bot.run
    end

    private

    def register_commands
      Commands::MemeCommand.new(bot: @bot, config: @config).register
      Commands::MusicCommand.new(bot: @bot, config: @config, voice_registry: @voice_registry).register
      register_ready_log
    end

    def register_ready_log
      @bot.ready do |event|
        puts "Pal is online as #{event.bot.profile.distinct}"
      end
    end
  end
end
