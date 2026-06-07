# frozen_string_literal: true

require "minitest/autorun"

require "pal/commands/music_command"

class MusicCommandTest < Minitest::Test
  FakeConfig = Struct.new(:guild_id)
  FakeEvent = Struct.new(:options)

  def test_defaults_to_join_when_no_action_is_supplied
    command = build_command
    event = FakeEvent.new({})

    assert_equal "gabung", command.action_from(event)
  end

  def test_reads_string_action_from_options
    command = build_command
    event = FakeEvent.new({ "aksi" => "status" })

    assert_equal "status", command.action_from(event)
  end

  def test_rejects_unknown_action
    command = build_command
    event = FakeEvent.new({ "aksi" => "acak" })

    assert_equal "gabung", command.action_from(event)
  end

  private

  def build_command
    Pal::Commands::MusicCommand.new(
      bot: Object.new,
      config: FakeConfig.new(nil),
      voice_registry: Object.new
    )
  end
end
