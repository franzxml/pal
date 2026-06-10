# frozen_string_literal: true

require "minitest/autorun"

require "pal/commands/play_command"
require "pal/queue_registry"
require "pal/voice_registry"

class PlayCommandTest < Minitest::Test
  FakeConfig = Struct.new(:guild_id)
  FakeServer = Struct.new(:id)
  FakeVoiceChannel = Struct.new(:id)
  FakeUser = Struct.new(:voice_channel)

  FakeChannel = Class.new do
    def send_message(_content); end
  end

  FakeCommandBuilder = Class.new do
    def string(_name, _desc, required: nil); end
  end

  FakeConnection = Class.new do
    def play_file(_url); end

    def stop_playing; end
  end

  FakeBot = Class.new do
    def initialize
      @handlers = {}
    end

    def register_application_command(*)
      yield FakeCommandBuilder.new if block_given?
    end

    def application_command(name, &block)
      @handlers[name] = block
    end

    def trigger(name, event)
      @handlers[name]&.call(event)
    end

    def voice_connect(_channel)
      FakeConnection.new
    end
  end

  FakeEvent = Struct.new(:user, :server, :channel, :options) do
    attr_reader :responses

    def initialize(...)
      super
      @responses = []
    end

    def respond(content:)
      @responses << content
    end
  end

  FakeResolver = Class.new do
    def resolve(url)
      "https://audio.example.com/#{url}"
    end
  end

  def setup
    @bot = FakeBot.new
    @voice_registry = Pal::VoiceRegistry.new
    @queue_registry = Pal::QueueRegistry.new
    @channel = FakeChannel.new

    @command = Pal::Commands::PlayCommand.new(
      bot: @bot,
      config: FakeConfig.new(nil),
      voice_registry: @voice_registry,
      queue_registry: @queue_registry,
      audio_source_resolver: FakeResolver.new
    )
    @command.register
  end

  def test_responds_with_error_when_user_not_in_voice_channel
    event = build_event(voice_channel: nil, url: "https://youtube.com/watch?v=test")

    @bot.trigger(:play, event)

    assert_includes event.responses.first, "voice channel"
    assert_equal 0, @queue_registry.size(1)
  end

  def test_responds_when_user_in_voice_channel
    event = build_event(voice_channel: FakeVoiceChannel.new(10), url: "https://youtube.com/watch?v=test")

    @bot.trigger(:play, event)
    sleep 0.05  # let drain thread start and respond

    assert_includes event.responses.first, "menyiapkan"
  end

  def test_second_play_reports_queue_position
    url = "https://youtube.com/watch?v=test"
    @queue_registry.enqueue(1, Pal::QueueRegistry::Track.new(url: url, channel: @channel))

    event = build_event(voice_channel: FakeVoiceChannel.new(10), url: url)
    @bot.trigger(:play, event)

    assert_includes event.responses.first, "antrean"
  end

  private

  def build_event(voice_channel:, url:)
    FakeEvent.new(FakeUser.new(voice_channel), FakeServer.new(1), @channel, { "url" => url })
  end
end
