require "minitest/autorun"

require "pal/config"

class ConfigTest < Minitest::Test
  def test_reads_required_environment
    config = Pal::Config.from_env(
      "DISCORD_BOT_TOKEN" => "token",
      "DISCORD_CLIENT_ID" => "client",
      "DISCORD_GUILD_ID" => " guild "
    )

    assert_equal "token", config.token
    assert_equal "client", config.client_id
    assert_equal "guild", config.guild_id
  end

  def test_rejects_missing_required_environment
    error = assert_raises(ArgumentError) do
      Pal::Config.from_env("DISCORD_BOT_TOKEN" => "token")
    end

    assert_includes error.message, "DISCORD_CLIENT_ID"
  end
end
