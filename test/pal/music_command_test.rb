require "minitest/autorun"
require "ostruct"

require "pal/commands/music_command"

class MusicCommandTest < Minitest::Test
  def test_defaults_to_join_when_no_action_is_supplied
    command = build_command
    event = OpenStruct.new(options: {})

    assert_equal "gabung", command.action_from(event)
  end

  def test_reads_string_action_from_options
    command = build_command
    event = OpenStruct.new(options: { "aksi" => "status" })

    assert_equal "status", command.action_from(event)
  end

  def test_rejects_unknown_action
    command = build_command
    event = OpenStruct.new(options: { "aksi" => "acak" })

    assert_equal "gabung", command.action_from(event)
  end

  private

  def build_command
    Pal::Commands::MusicCommand.new(
      bot: Object.new,
      config: OpenStruct.new(guild_id: nil),
      voice_registry: Object.new
    )
  end
end
