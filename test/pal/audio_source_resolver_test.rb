# frozen_string_literal: true

require "minitest/autorun"

require "pal/audio_source_resolver"

class AudioSourceResolverTest < Minitest::Test
  def setup
    @resolver = Pal::AudioSourceResolver.new
  end

  def test_rejects_non_youtube_urls
    error = assert_raises(Pal::AudioSourceResolver::Error) do
      @resolver.resolve("https://example.com/video")
    end

    assert_includes error.message, "YouTube"
  end

  def test_rejects_invalid_urls
    error = assert_raises(Pal::AudioSourceResolver::Error) do
      @resolver.resolve("bukan-url")
    end

    assert_includes error.message, "tidak valid"
  end
end
