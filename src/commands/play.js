import { SlashCommandBuilder } from "discord.js";
import { connectToVoice, getSession, playNext } from "../voice/manager.js";
import { validateYouTubeUrl } from "../voice/resolver.js";

const definition = new SlashCommandBuilder()
  .setName("play")
  .setDescription("Putar audio dari URL YouTube.")
  .addStringOption((option) =>
    option
      .setName("url")
      .setDescription("URL YouTube yang ingin diputar.")
      .setRequired(true),
  )
  .toJSON();

async function handle(interaction) {
  const url = interaction.options.getString("url", true);

  if (!validateYouTubeUrl(url)) {
    await interaction.reply({ content: "URL harus berasal dari YouTube.", ephemeral: true });
    return;
  }

  if (!interaction.member?.voice?.channel) {
    await interaction.reply({ content: "Masuk ke voice channel dulu, lalu jalankan `/play` lagi.", ephemeral: true });
    return;
  }

  const key = interaction.guildId;
  await interaction.reply("PAL menambahkan audio YouTube ke antrean.");

  try {
    const connection = await connectToVoice(interaction);
    const session = getSession(key);
    connection.subscribe(session.player);
    session.queue.push({ interaction, requestedBy: interaction.user.id, url });

    if (session.current) {
      await interaction.followUp(`Audio masuk antrean posisi ${session.queue.length}.`);
    }

    await playNext(key);
  } catch (error) {
    console.error("Failed to play YouTube audio:", error);
    await interaction.followUp({ content: `Gagal memutar audio: ${error.message}`, ephemeral: true });
  }
}

export { definition, handle };
