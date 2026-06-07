# frozen_string_literal: true

module Pal
  class VoiceRegistry
    def initialize
      @connections = {}
      @mutex = Mutex.new
    end

    def register(guild_id, connection)
      @mutex.synchronize { @connections[guild_id] = connection }
    end

    def delete(guild_id)
      @mutex.synchronize { @connections.delete(guild_id) }
    end

    def fetch(guild_id)
      @mutex.synchronize { @connections[guild_id] }
    end

    def connected?(guild_id)
      @mutex.synchronize { @connections.key?(guild_id) }
    end
  end
end
