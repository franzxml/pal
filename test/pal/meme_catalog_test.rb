# frozen_string_literal: true

require "minitest/autorun"

require "pal/meme_catalog"

class MemeCatalogTest < Minitest::Test
  FakeRandom = Struct.new(:value) do
    def rand(_max)
      value
    end
  end

  def test_returns_a_meme_url
    assert_match %r{\Ahttps://}, Pal::MemeCatalog.random(FakeRandom.new(0))
  end
end
