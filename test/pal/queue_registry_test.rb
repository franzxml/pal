# frozen_string_literal: true

require "minitest/autorun"

require "pal/queue_registry"

class QueueRegistryTest < Minitest::Test
  def setup
    @registry = Pal::QueueRegistry.new
    @track = Pal::QueueRegistry::Track.new(url: "https://youtube.com/watch?v=test", channel: nil)
  end

  def test_enqueue_returns_position_one_and_should_start_when_idle
    result = @registry.enqueue(1, @track)

    assert_equal 1, result[:position]
    assert result[:should_start]
  end

  def test_enqueue_returns_should_start_false_when_already_playing
    @registry.enqueue(1, @track)
    result = @registry.enqueue(1, @track)

    assert_equal 2, result[:position]
    refute result[:should_start]
  end

  def test_dequeue_returns_tracks_in_fifo_order
    track_a = Pal::QueueRegistry::Track.new(url: "a", channel: nil)
    track_b = Pal::QueueRegistry::Track.new(url: "b", channel: nil)
    @registry.enqueue(1, track_a)
    @registry.enqueue(1, track_b)

    assert_same track_a, @registry.dequeue(1)
    assert_same track_b, @registry.dequeue(1)
  end

  def test_dequeue_returns_nil_and_clears_playing_flag_when_queue_empty
    @registry.enqueue(1, @track)
    @registry.dequeue(1)

    assert_nil @registry.dequeue(1)
    refute @registry.playing?(1)
  end

  def test_new_enqueue_after_drain_can_start_fresh_worker
    @registry.enqueue(1, @track)
    @registry.dequeue(1)  # dequeues track
    @registry.dequeue(1)  # returns nil, sets playing=false

    result = @registry.enqueue(1, @track)

    assert result[:should_start]
  end

  def test_clear_removes_queued_tracks_and_returns_count
    @registry.enqueue(1, @track)
    @registry.enqueue(1, @track)

    count = @registry.clear(1)

    assert_equal 2, count
    assert_equal 0, @registry.size(1)
  end

  def test_clear_returns_zero_for_unknown_guild
    assert_equal 0, @registry.clear(999)
  end

  def test_playing_true_after_enqueue_false_initially
    refute @registry.playing?(1)

    @registry.enqueue(1, @track)

    assert @registry.playing?(1)
  end

  def test_reset_clears_queue_and_sets_playing_false
    @registry.enqueue(1, @track)
    @registry.enqueue(1, @track)

    @registry.reset(1)

    refute @registry.playing?(1)
    assert_equal 0, @registry.size(1)
  end

  def test_multiple_guilds_are_independent
    track_a = Pal::QueueRegistry::Track.new(url: "a", channel: nil)
    track_b = Pal::QueueRegistry::Track.new(url: "b", channel: nil)
    @registry.enqueue(1, track_a)
    @registry.enqueue(2, track_b)

    assert_same track_a, @registry.dequeue(1)
    assert_same track_b, @registry.dequeue(2)
  end

  def test_concurrent_enqueue_only_one_should_start
    start_gate = Queue.new
    results = []
    mutex = Mutex.new

    threads = Array.new(5) do
      Thread.new do
        start_gate.pop
        result = @registry.enqueue(1, @track)
        mutex.synchronize { results << result }
      end
    end

    5.times { start_gate << true }
    threads.each(&:join)

    starts = results.count { |r| r[:should_start] }

    assert_equal 1, starts
  end
end
