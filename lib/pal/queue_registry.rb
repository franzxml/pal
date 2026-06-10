# frozen_string_literal: true

module Pal
  class QueueRegistry
    Track = Struct.new(:url, :channel, keyword_init: true)

    def initialize
      @state = {}
      @mutex = Mutex.new
    end

    # Returns { position:, should_start: } where should_start is true iff
    # the caller must spawn the drain worker (no worker was running before).
    def enqueue(guild_id, track)
      @mutex.synchronize do
        @state[guild_id] ||= { queue: [], playing: false }
        entry = @state[guild_id]
        entry[:queue] << track
        should_start = !entry[:playing]
        entry[:playing] = true if should_start
        { position: entry[:queue].length, should_start: should_start }
      end
    end

    # Returns the next track or nil when the queue is empty.
    # Sets playing=false when returning nil so a subsequent enqueue can start a new worker.
    def dequeue(guild_id)
      @mutex.synchronize do
        entry = @state[guild_id]
        return nil unless entry

        track = entry[:queue].shift
        entry[:playing] = false if track.nil?
        track
      end
    end

    def clear(guild_id)
      @mutex.synchronize do
        return 0 unless @state[guild_id]

        count = @state[guild_id][:queue].length
        @state[guild_id][:queue].clear
        count
      end
    end

    def size(guild_id)
      @mutex.synchronize { @state.dig(guild_id, :queue)&.length || 0 }
    end

    def playing?(guild_id)
      @mutex.synchronize { @state.dig(guild_id, :playing) || false }
    end

    # Force-clears queue and resets playing flag. Used after an unrecoverable drain error.
    def reset(guild_id)
      @mutex.synchronize do
        return unless @state[guild_id]

        @state[guild_id][:queue].clear
        @state[guild_id][:playing] = false
      end
    end
  end
end
