require("dotenv").config();

const { execFile } = require("node:child_process");
const { promisify } = require("node:util");
const {
  Client,
  GatewayIntentBits,
  REST,
  Routes,
  SlashCommandBuilder,
} = require("discord.js");
const {
  AudioPlayerStatus,
  NoSubscriberBehavior,
  VoiceConnectionStatus,
  createAudioPlayer,
  createAudioResource,
  entersState,
  joinVoiceChannel,
} = require("@discordjs/voice");

const execFileAsync = promisify(execFile);

const token = process.env.DISCORD_BOT_TOKEN;
const clientId = process.env.DISCORD_CLIENT_ID;
const guildId = process.env.DISCORD_GUILD_ID;

if (!token || !clientId) {
  throw new Error("DISCORD_BOT_TOKEN dan DISCORD_CLIENT_ID wajib diisi.");
}

const memeUrls = [
  "https://i.imgflip.com/30b1gx.jpg",
  "https://i.imgflip.com/1bij.jpg",
  "https://i.imgflip.com/26am.jpg",
  "https://i.imgflip.com/1otk96.jpg",
  "https://i.imgflip.com/3si4.jpg",
  "https://i.imgflip.com/4t0m5.jpg",
];

const connections = new Map();
const players = new Map();

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildVoiceStates],
});

const commands = [
  new SlashCommandBuilder()
    .setName("meme")
    .setDescription("Kirim meme acak ke kanal ini."),
  new SlashCommandBuilder()
    .setName("musik")
    .setDescription("Kontrol fitur musik PAL.")
    .addStringOption((option) =>
      option
        .setName("aksi")
        .setDescription("Pilih aksi musik.")
        .setRequired(false)
        .addChoices(
          { name: "gabung", value: "gabung" },
          { name: "keluar", value: "keluar" },
          { name: "status", value: "status" },
        ),
    ),
  new SlashCommandBuilder()
    .setName("play")
    .setDescription("Putar audio dari URL YouTube.")
    .addStringOption((option) =>
      option
        .setName("url")
        .setDescription("URL YouTube yang ingin diputar.")
        .setRequired(true),
    ),
  new SlashCommandBuilder()
    .setName("stop")
    .setDescription("Hentikan audio yang sedang diputar PAL."),
].map((command) => command.toJSON());

async function registerCommands() {
  const rest = new REST({ version: "10" }).setToken(token);
  if (guildId) {
    await rest.put(Routes.applicationGuildCommands(clientId, guildId), { body: commands });
    return;
  }

  await rest.put(Routes.applicationCommands(clientId), { body: commands });
}

function guildKey(interaction) {
  return interaction.guildId;
}

function memberVoiceChannel(interaction) {
  return interaction.member?.voice?.channel;
}

async function connectToVoice(interaction) {
  const voiceChannel = memberVoiceChannel(interaction);
  if (!voiceChannel) {
    throw new Error("Masuk ke voice channel dulu, lalu jalankan command lagi.");
  }

  const key = guildKey(interaction);
  const existing = connections.get(key);
  if (existing) {
    return existing;
  }

  const connection = joinVoiceChannel({
    channelId: voiceChannel.id,
    guildId: interaction.guildId,
    adapterCreator: interaction.guild.voiceAdapterCreator,
    selfDeaf: false,
  });

  await entersState(connection, VoiceConnectionStatus.Ready, 20_000);
  connections.set(key, connection);
  return connection;
}

async function resolveYouTubeAudio(url) {
  const parsed = new URL(url);
  const host = parsed.hostname.toLowerCase();
  if (!host.endsWith("youtube.com") && host !== "youtu.be") {
    throw new Error("URL harus berasal dari YouTube.");
  }

  const { stdout } = await execFileAsync(
    "yt-dlp",
    ["--no-playlist", "--format", "bestaudio/best", "--get-url", parsed.toString()],
    { timeout: 45_000, maxBuffer: 1024 * 1024 },
  );

  const audioUrl = stdout.split("\n").find((line) => line.trim()).trim();
  if (!audioUrl) {
    throw new Error("yt-dlp tidak mengembalikan URL audio.");
  }

  return audioUrl;
}

async function handleMeme(interaction) {
  const index = Math.floor(Math.random() * memeUrls.length);
  await interaction.reply(memeUrls[index]);
}

async function handleMusic(interaction) {
  const action = interaction.options.getString("aksi") || "gabung";

  if (action === "status") {
    const connection = connections.get(guildKey(interaction));
    await interaction.reply(connection ? "PAL sedang tersambung ke voice channel." : "PAL belum tersambung ke voice channel.");
    return;
  }

  if (action === "keluar") {
    const key = guildKey(interaction);
    const player = players.get(key);
    const connection = connections.get(key);

    if (player) {
      player.stop(true);
      players.delete(key);
    }

    if (connection) {
      connection.destroy();
      connections.delete(key);
      await interaction.reply("PAL sudah keluar dari voice channel.");
      return;
    }

    await interaction.reply("PAL belum tersambung ke voice channel di server ini.");
    return;
  }

  await interaction.reply("PAL sedang mencoba masuk ke voice channel.");
  try {
    await connectToVoice(interaction);
    await interaction.followUp("PAL sudah masuk ke voice channel.");
  } catch (error) {
    await interaction.followUp(error.message);
  }
}

async function handlePlay(interaction) {
  const url = interaction.options.getString("url", true);
  const key = guildKey(interaction);

  await interaction.reply("PAL sedang menyiapkan audio dari YouTube.");

  try {
    const connection = await connectToVoice(interaction);
    const audioUrl = await resolveYouTubeAudio(url);
    const player = createAudioPlayer({
      behaviors: {
        noSubscriber: NoSubscriberBehavior.Play,
      },
    });
    const resource = createAudioResource(audioUrl);

    player.on("error", async (error) => {
      console.error("Audio player error:", error);
      try {
        await interaction.followUp("Playback gagal saat audio sedang diputar.");
      } catch (_) {
      }
    });

    player.once(AudioPlayerStatus.Playing, async () => {
      try {
        await interaction.followUp("PAL mulai memutar audio.");
      } catch (_) {
      }
    });

    players.get(key)?.stop(true);
    players.set(key, player);
    connection.subscribe(player);
    player.play(resource);
  } catch (error) {
    console.error("Failed to play YouTube audio:", error);
    await interaction.followUp(`Gagal memutar audio: ${error.message}`);
  }
}

async function handleStop(interaction) {
  const player = players.get(guildKey(interaction));
  if (!player) {
    await interaction.reply("Tidak ada audio yang sedang diputar.");
    return;
  }

  player.stop(true);
  players.delete(guildKey(interaction));
  await interaction.reply("Playback PAL sudah dihentikan.");
}

client.once("ready", () => {
  console.log(`PAL is online as ${client.user.tag}`);
});

client.on("interactionCreate", async (interaction) => {
  if (!interaction.isChatInputCommand()) {
    return;
  }

  try {
    if (interaction.commandName === "meme") {
      await handleMeme(interaction);
    } else if (interaction.commandName === "musik") {
      await handleMusic(interaction);
    } else if (interaction.commandName === "play") {
      await handlePlay(interaction);
    } else if (interaction.commandName === "stop") {
      await handleStop(interaction);
    }
  } catch (error) {
    console.error(`Failed to handle /${interaction.commandName}:`, error);
    const message = "Maaf, PAL gagal menjalankan command itu.";
    if (interaction.replied || interaction.deferred) {
      await interaction.followUp(message);
    } else {
      await interaction.reply(message);
    }
  }
});

registerCommands()
  .then(() => client.login(token))
  .catch((error) => {
    console.error("Failed to start PAL:", error);
    process.exit(1);
  });
