# frozen_string_literal: true

module Pal
  class VoiceRegistry
    def initialize
      @connections = {}
      @guild_locks = {}
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

    # Mencegah race check-then-act: pemanggilan bersamaan untuk guild yang sama
    # hanya menjalankan block sekali dan memakai satu koneksi yang sama.
    def fetch_or_register(guild_id)
      guild_lock(guild_id).synchronize do
        existing = fetch(guild_id)
        next existing if existing

        connection = yield
        register(guild_id, connection)
        connection
      end
    end

    private

    def guild_lock(guild_id)
      @mutex.synchronize { @guild_locks[guild_id] ||= Mutex.new }
    end
  end
end
