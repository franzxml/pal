const MEME_URLS = [
  "https://i.imgflip.com/30b1gx.jpg",
  "https://i.imgflip.com/1bij.jpg",
  "https://i.imgflip.com/26am.jpg",
  "https://i.imgflip.com/1otk96.jpg",
  "https://i.imgflip.com/3si4.jpg",
  "https://i.imgflip.com/4t0m5.jpg",
];

function randomMeme() {
  return MEME_URLS[Math.floor(Math.random() * MEME_URLS.length)];
}

export { randomMeme };
