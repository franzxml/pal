## Fitur
* Slash command `/meme` untuk mengirim meme acak ke kanal Discord
* Slash command `/musik` untuk mengontrol koneksi voice dasar
* Slash command `/play` untuk memutar audio dari URL YouTube
* Slash command `/stop` untuk menghentikan audio yang sedang diputar
* Slash command `/queue` untuk melihat antrean musik
* Sistem antrean musik per server agar `/play` berikutnya menunggu lagu aktif selesai
* Aksi musik `gabung` untuk membuat bot masuk ke voice channel pengguna
* Aksi musik `keluar` untuk membuat bot keluar dari voice channel
* Aksi musik `status` untuk mengecek koneksi voice bot
* Validasi konfigurasi environment wajib sebelum bot dijalankan
* Pembacaan file `.env` otomatis saat menjalankan bot
* Tidak membutuhkan database pada versi awal
* Penyimpanan koneksi voice sementara selama proses bot berjalan
* Dukungan voice Discord terbaru melalui DAVE/E2EE
* Struktur command yang modular dan mudah dikembangkan
* Runtime Node.js untuk voice musik YouTube
* Struktur backend Ruby tetap tersedia sebagai fondasi awal
* Unit test untuk konfigurasi, katalog meme, command musik, dan registry voice

## Teknologi
* Ruby
* discordrb
* Bundler
* Rake
* Minitest
* Node.js
* discord.js
* @discordjs/voice
* @snazzah/davey
* dotenv
* yt-dlp
* FFmpeg
* Discord API
* Discord slash command
* Discord voice channel
* libsodium

## Struktur Folder
    pal/
    │── bin/
    │   └── pal
    │── lib/
    │   ├── pal/
    │   │   ├── commands/
    │   │   │   ├── meme_command.rb
    │   │   │   ├── music_command.rb
    │   │   │   ├── play_command.rb
    │   │   │   └── stop_command.rb
    │   │   ├── audio_source_resolver.rb
    │   │   ├── bot.rb
    │   │   ├── commands.rb
    │   │   ├── config.rb
    │   │   ├── meme_catalog.rb
    │   │   ├── version.rb
    │   │   └── voice_registry.rb
    │   └── pal.rb
    │── test/
    │   └── pal/
    │       ├── audio_source_resolver_test.rb
    │       ├── config_test.rb
    │       ├── meme_catalog_test.rb
    │       ├── music_command_test.rb
    │       └── voice_registry_test.rb
    │── src/
    │   └── index.js
    │── .env.example
    │── .gitignore
    │── .ruby-version
    │── Gemfile
    │── Gemfile.lock
    │── package-lock.json
    │── package.json
    │── README.md
    └── Rakefile

## Cara Menjalankan
1. **Persiapan Lingkungan:** Pastikan komputer sudah terinstal **Node.js 22+**, **npm**, **yt-dlp**, dan **FFmpeg** untuk fitur musik YouTube.

2. **Masuk ke Folder Proyek:**
   ```bash
   cd pal
   ```

3. **Install Dependensi Node.js:**
   ```bash
   npm install
   ```

4. **Siapkan Environment:** Salin file contoh environment, lalu isi token dan ID Discord.
   ```bash
   cp .env.example .env
   ```

   Isi `.env`:
   ```bash
   DISCORD_BOT_TOKEN=token_bot_discord
   DISCORD_CLIENT_ID=application_client_id
   DISCORD_GUILD_ID=id_server_discord
   ```

5. **Invite Bot ke Server Discord:** Invite bot melalui Discord Developer Portal dengan scope `bot` dan `applications.commands`.

6. **Jalankan PAL:**
   ```bash
   npm start
   ```

7. **Gunakan Bot di Discord:** Jalankan command berikut dari server Discord:
   ```bash
   /meme
   /musik
   /play
   /stop
   /queue
   ```

   Untuk `/musik gabung` dan `/play`, pastikan pengguna sudah berada di voice channel.
   Jika audio sedang diputar, command `/play` berikutnya akan otomatis masuk antrean.

## Script
* `npm install` untuk menginstall dependensi runtime Node.js.
* `npm start` untuk menjalankan PAL dengan dukungan voice DAVE/E2EE.
* `npm run voice:report` untuk mengecek dependency voice, DAVE, Opus, dan FFmpeg.
* `node --check src/index.js` untuk mengecek sintaks runtime Node.js.
* `bundle install` untuk menginstall dependensi Ruby.
* `bundle exec ruby bin/pal` untuk menjalankan runtime Ruby lama.
* `bundle exec rake test` untuk menjalankan unit test Ruby.
* `ruby -c lib/pal/bot.rb` untuk mengecek sintaks file bot utama.

## Catatan Discord
Bot membutuhkan aplikasi Discord yang dibuat melalui Discord Developer Portal.

Permission yang direkomendasikan:
* `Send Messages`
* `Use Slash Commands`
* `Connect`
* `Speak`

Saat pengembangan, isi `DISCORD_GUILD_ID` agar update slash command muncul cepat di satu server. Jika `DISCORD_GUILD_ID` kosong, command akan didaftarkan secara global dan bisa membutuhkan waktu lebih lama untuk muncul di Discord.

## Catatan Voice
Fitur voice Discord sekarang membutuhkan dukungan DAVE/E2EE. Runtime Node.js di `src/index.js` memakai `@discordjs/voice` dan `@snazzah/davey` agar PAL bisa tersambung ke voice channel modern.

Untuk macOS dengan Homebrew, dependency native dapat diinstall menggunakan:
```bash
brew install yt-dlp ffmpeg opus libsodium
```

---

Dikembangkan oleh:

* @franzxml
