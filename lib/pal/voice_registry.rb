module Pal
  class VoiceRegistry
    def initialize
      @connections = {}
    end

    def register(guild_id, connection)
      @connections[guild_id] = connection
    end

    def delete(guild_id)
      @connections.delete(guild_id)
    end

    def connected?(guild_id)
      @connections.key?(guild_id)
    end
  end
end
