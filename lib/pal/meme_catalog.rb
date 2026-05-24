module Pal
  module MemeCatalog
    MEMES = [
      "https://i.imgflip.com/30b1gx.jpg",
      "https://i.imgflip.com/1bij.jpg",
      "https://i.imgflip.com/26am.jpg",
      "https://i.imgflip.com/1otk96.jpg",
      "https://i.imgflip.com/3si4.jpg",
      "https://i.imgflip.com/4t0m5.jpg"
    ].freeze

    module_function

    def random(randomizer = Random)
      MEMES.fetch(randomizer.rand(MEMES.length))
    end
  end
end
