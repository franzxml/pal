# frozen_string_literal: true

require "minitest/autorun"

require "pal/voice_registry"

class VoiceRegistryTest < Minitest::Test
  def test_tracks_voice_connection_by_guild
    registry = Pal::VoiceRegistry.new
    connection = Object.new

    registry.register(123, connection)

    assert registry.connected?(123)
    assert_same connection, registry.fetch(123)
    assert_same connection, registry.delete(123)
    refute registry.connected?(123)
  end
end
