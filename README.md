## Fitur

- `/meme` — kirim meme acak ke channel
- `/play <url>` — putar audio dari URL YouTube, masuk ke antrean
- `/queue` — lihat antrean musik yang sedang berjalan
- `/stop` — hentikan playback dan kosongkan antrean
- `/musik gabung` — PAL masuk ke voice channel pengguna
- `/musik keluar` — PAL keluar dari voice channel
- `/musik status` — cek status koneksi dan antrean

## Teknologi

- **Runtime:** Node.js 22, Ruby 3.2.2
- **Discord (Node.js):** discord.js v14, @discordjs/voice
- **Discord (Ruby):** discordrb
- **Audio:** yt-dlp, FFmpeg, opusscript
- **Utilitas:** dotenv
- **Test:** Minitest (Ruby), Rake
- **Linting:** ESLint (JavaScript), RuboCop (Ruby)

## Struktur Folder

```
pal/
|-- bin/
|   `-- pal                Entry point CLI untuk menjalankan bot Ruby
|-- lib/
|   `-- pal/               Implementasi Ruby (discordrb)
|       `-- commands/      Handler slash command Ruby
|-- src/
|   |-- commands/
|   |   |-- meme.js        Handler /meme
|   |   |-- music.js       Handler /musik
|   |   |-- play.js        Handler /play
|   |   |-- queue.js       Handler /queue
|   |   `-- stop.js        Handler /stop
|   |-- voice/
|   |   |-- manager.js     Connection & session management, playNext
|   |   `-- resolver.js    resolveYouTubeAudio, validasi URL YouTube
|   |-- config.js          Semua env var terpusat
|   `-- index.js           Entry point Node.js
|-- test/
|   `-- pal/               Test suite Minitest untuk implementasi Ruby
|-- .env.example           Template environment variable
|-- Gemfile                Dependency Ruby
|-- Rakefile               Task runner (default: jalankan test suite Ruby)
`-- package.json           Dependency Node.js
```

## Cara Menjalankan

**Prasyarat sistem:**

```bash
brew install yt-dlp ffmpeg   # macOS
```

**Langkah:**

1. Clone repositori:
   ```bash
   git clone https://github.com/franzxml/pal.git
   cd pal
   ```

2. Install dependency Node.js:
   ```bash
   npm install
   ```

3. Install dependency Ruby:
   ```bash
   bundle install
   ```

4. Salin template environment dan isi nilainya:
   ```bash
   cp .env.example .env
   ```

   Buka `.env` dan isi:
   ```
   DISCORD_BOT_TOKEN=token_bot_dari_discord_developer_portal
   DISCORD_CLIENT_ID=application_id_dari_discord_developer_portal
   DISCORD_GUILD_ID=id_server_discord_untuk_development  # kosongkan untuk registrasi global
   ```

5. Jalankan bot:
   ```bash
   npm start
   ```

Slash command otomatis terdaftar ke guild (jika `DISCORD_GUILD_ID` diisi) atau ke global saat bot start.

## Scripts

| Perintah | Keterangan |
|---|---|
| `npm start` | Jalankan bot Discord (Node.js) |
| `npm run lint` | Periksa kode JavaScript dengan ESLint |
| `npm run voice:report` | Cetak laporan dependency `@discordjs/voice` |
| `bundle exec rake test` | Jalankan seluruh test suite Ruby |
| `bundle exec rake` | Sama dengan `rake test` (default task) |
| `bundle exec rubocop` | Periksa kode Ruby dengan RuboCop |

## Pengembang

- [franzxml](https://github.com/franzxml)
