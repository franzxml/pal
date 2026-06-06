# frozen_string_literal: true

module Pal
  class Config
    REQUIRED_ENV = {
      "DISCORD_BOT_TOKEN" => "Discord bot token",
      "DISCORD_CLIENT_ID" => "Discord application client ID"
    }.freeze

    attr_reader :token, :client_id, :guild_id

    def self.from_env(env = ENV)
      missing = REQUIRED_ENV.keys.select { |key| blank?(env[key]) }
      unless missing.empty?
        names = missing.join(", ")
        raise ArgumentError, "Missing required environment variables: #{names}"
      end

      new(
        token: env.fetch("DISCORD_BOT_TOKEN"),
        client_id: env.fetch("DISCORD_CLIENT_ID"),
        guild_id: presence(env["DISCORD_GUILD_ID"])
      )
    end

    def self.blank?(value)
      value.nil? || value.strip.empty?
    end

    def self.presence(value)
      blank?(value) ? nil : value.strip
    end

    def initialize(token:, client_id:, guild_id: nil)
      @token = token
      @client_id = client_id
      @guild_id = guild_id
    end
  end
end
