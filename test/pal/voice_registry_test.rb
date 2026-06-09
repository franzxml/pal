# frozen_string_literal: true

require "minitest/autorun"

require "pal/voice_registry"

class VoiceRegistryTest < Minitest::Test
  def setup
    @registry = Pal::VoiceRegistry.new
  end

  def test_tracks_voice_connection_by_guild
    connection = Object.new

    @registry.register(123, connection)

    assert @registry.connected?(123)
    assert_same connection, @registry.fetch(123)
    assert_same connection, @registry.delete(123)
    refute @registry.connected?(123)
  end

  def test_fetch_or_register_creates_and_stores_connection_when_absent
    connection = Object.new

    result = @registry.fetch_or_register(123) { connection }

    assert_same connection, result
    assert_same connection, @registry.fetch(123)
  end

  def test_fetch_or_register_returns_existing_connection_without_calling_block
    existing = Object.new
    @registry.register(123, existing)

    result = @registry.fetch_or_register(123) { flunk "Block tidak boleh dipanggil saat koneksi sudah ada." }

    assert_same existing, result
  end

  def test_fetch_or_register_creates_single_connection_for_concurrent_calls
    call_count = 0
    start_gate = Queue.new

    threads = Array.new(5) do
      Thread.new do
        start_gate.pop
        @registry.fetch_or_register(123) do
          call_count += 1
          sleep 0.01
          Object.new
        end
      end
    end

    5.times { start_gate << true }
    results = threads.map(&:value)

    assert_equal 1, call_count
    assert_equal 1, results.uniq(&:object_id).length
  end
end
