## Fitur
* Slash command `/meme` untuk mengirim meme acak ke kanal Discord
* Slash command `/musik` untuk mengontrol koneksi voice dasar
* Aksi musik `gabung` untuk membuat bot masuk ke voice channel pengguna
* Aksi musik `keluar` untuk membuat bot keluar dari voice channel
* Aksi musik `status` untuk mengecek koneksi voice bot
* Validasi konfigurasi environment wajib sebelum bot dijalankan
* Pembacaan file `.env` otomatis saat menjalankan bot
* Tidak membutuhkan database pada versi awal
* Penyimpanan koneksi voice sementara selama proses bot berjalan
* Struktur command yang modular dan mudah dikembangkan
* Struktur backend Ruby yang sederhana dan mudah dipahami
* Unit test untuk konfigurasi, katalog meme, command musik, dan registry voice

## Teknologi
* Ruby
* discordrb
* dotenv
* Bundler
* Rake
* Minitest
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
    │   │   │   └── music_command.rb
    │   │   ├── bot.rb
    │   │   ├── commands.rb
    │   │   ├── config.rb
    │   │   ├── meme_catalog.rb
    │   │   ├── version.rb
    │   │   └── voice_registry.rb
    │   └── pal.rb
    │── test/
    │   └── pal/
    │       ├── config_test.rb
    │       ├── meme_catalog_test.rb
    │       ├── music_command_test.rb
    │       └── voice_registry_test.rb
    │── .env.example
    │── .gitignore
    │── .ruby-version
    │── Gemfile
    │── Gemfile.lock
    │── README.md
    │── Rakefile
    └── prd.md

## Cara Menjalankan
1. **Persiapan Lingkungan:** Pastikan komputer sudah terinstal **Ruby 2.7+**, **Bundler**, dan **libsodium** untuk fitur voice.

2. **Masuk ke Folder Proyek:**
   ```bash
   cd pal
   ```

3. **Install Dependensi:**
   ```bash
   bundle install
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

6. **Jalankan Bot:**
   ```bash
   bundle exec ruby bin/pal
   ```

7. **Gunakan Bot di Discord:** Jalankan command berikut dari server Discord:
   ```bash
   /meme
   /musik
   ```

   Untuk `/musik gabung`, pastikan pengguna sudah berada di voice channel.

## Script
* `bundle install` untuk menginstall dependensi aplikasi.
* `bundle exec ruby bin/pal` untuk menjalankan bot Discord.
* `bundle exec rake test` untuk menjalankan unit test.
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
Fitur voice membutuhkan `libsodium`. Tanpa library ini, command teks tetap dapat berjalan, tetapi koneksi voice tidak akan aktif.

Untuk macOS dengan Homebrew, `libsodium` dapat diinstall menggunakan:
```bash
brew install libsodium
```

---

Dikembangkan oleh:

* @franzxml