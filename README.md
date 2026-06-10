## Fitur

- `/play <url>` — putar audio dari URL YouTube, masuk ke antrean
- `/queue` — lihat antrean musik yang sedang berjalan
- `/stop` — hentikan playback dan kosongkan antrean
- `/musik [aksi]` — kontrol koneksi voice channel (gabung/keluar/status)
- `/meme` — kirim meme acak ke channel

## Teknologi

- **Runtime:** Node.js 22, Ruby 3.2.2
- **Discord (Node.js):** discord.js 14, @discordjs/voice
- **Discord (Ruby):** discordrb 3.5
- **Eksternal:** yt-dlp, ffmpeg

## Struktur Folder

```
pal/
├── src/                        Implementasi Node.js (discord.js)
│   ├── commands/               Handler slash command
│   ├── voice/                  Manajemen koneksi voice
│   ├── config.js               Pembacaan environment variable terpusat
│   └── index.js                Entry point
├── lib/                        Implementasi Ruby (discordrb)
│   └── pal/
│       ├── commands/           Handler command Ruby
│       └── ...
├── test/                       Test suite Ruby (Minitest)
├── bin/
│   └── pal                     CLI entry point Ruby
├── .env.example                Template environment variable
└── package.json
```

## Cara Menjalankan

**Prasyarat sistem:**
```bash
brew install yt-dlp ffmpeg ruby@3.2   # macOS
echo 'export PATH="/opt/homebrew/opt/ruby@3.2/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

1. Clone repositori:
   ```bash
   git clone https://github.com/franzxml/pal.git && cd pal
   ```

2. Install dependency:
   ```bash
   npm install
   bundle install
   ```

3. Salin template environment dan isi nilainya:
   ```bash
   cp .env.example .env
   ```

4. Jalankan bot:
   ```bash
   npm start
   ```

## Scripts

| Perintah | Keterangan |
|---|---|
| `npm start` | Jalankan bot Discord (Node.js) |
| `npm run lint` | Periksa kode JavaScript dengan ESLint |
| `npm run voice:report` | Cek status dependency voice (ffmpeg, opus) |
| `bundle exec rake test` | Jalankan seluruh test suite Ruby |
| `bundle exec rubocop` | Lint kode Ruby |

## Pengembang

- [franzxml](https://github.com/franzxml)
