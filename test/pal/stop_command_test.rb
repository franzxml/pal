# frozen_string_literal: true

require "minitest/autorun"

require "pal/commands/stop_command"
require "pal/queue_registry"
require "pal/voice_registry"

class StopCommandTest < Minitest::Test
  FakeConfig = Struct.new(:guild_id)
  FakeServer = Struct.new(:id)

  FakeChannel = Class.new do
    def id
      99
    end
  end

  FakeConnection = Class.new do
    attr_reader :stopped

    def initialize
      @stopped = false
    end

    def stop_playing
      @stopped = true
    end
  end

  FakeBot = Class.new do
    def initialize
      @handlers = {}
    end

    def register_application_command(_name, _desc, server_id: nil); end

    def application_command(name, &block)
      @handlers[name] = block
    end

    def trigger(name, event)
      @handlers[name]&.call(event)
    end
  end

  FakeEvent = Struct.new(:server, :channel) do
    attr_reader :responses

    def initialize(...)
      super
      @responses = []
    end

    def respond(content:)
      @responses << content
    end
  end

  def setup
    @bot = FakeBot.new
    @voice_registry = Pal::VoiceRegistry.new
    @queue_registry = Pal::QueueRegistry.new

    @command = Pal::Commands::StopCommand.new(
      bot: @bot,
      config: FakeConfig.new(nil),
      voice_registry: @voice_registry,
      queue_registry: @queue_registry
    )
    @command.register
  end

  def test_responds_not_connected_when_no_voice_connection
    event = FakeEvent.new(FakeServer.new(1), FakeChannel.new)

    @bot.trigger(:stop, event)

    assert_includes event.responses.first, "belum tersambung"
  end

  def test_stops_playback_and_clears_queue_when_connected
    connection = FakeConnection.new
    @voice_registry.register(1, connection)
    track = Pal::QueueRegistry::Track.new(url: "https://youtube.com/watch?v=test", channel: FakeChannel.new)
    @queue_registry.enqueue(1, track)
    @queue_registry.enqueue(1, track)

    event = FakeEvent.new(FakeServer.new(1), FakeChannel.new)
    @bot.trigger(:stop, event)

    assert connection.stopped
    assert_equal 0, @queue_registry.size(1)
    assert_includes event.responses.first, "dihentikan"
  end
end
