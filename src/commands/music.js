import { SlashCommandBuilder } from "discord.js";
import { connectToVoice, getConnection, findSession, destroySession } from "../voice/manager.js";

const definition = new SlashCommandBuilder()
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
  )
  .toJSON();

async function handle(interaction) {
  const action = interaction.options.getString("aksi") ?? "gabung";
  const key = interaction.guildId;

  if (action === "status") {
    const connection = getConnection(key);
    if (!connection) {
      await interaction.reply({ content: "PAL belum tersambung ke voice channel.", ephemeral: true });
      return;
    }
    const session = findSession(key);
    const queueLength = session?.queue.length ?? 0;
    const status = session?.current ? "sedang memutar audio" : "tidak sedang memutar audio";
    await interaction.reply({ content: `PAL tersambung dan ${status}. Antrean: ${queueLength}.`, ephemeral: true });
    return;
  }

  if (action === "keluar") {
    const connection = getConnection(key);
    if (!connection) {
      await interaction.reply({ content: "PAL belum tersambung ke voice channel di server ini.", ephemeral: true });
      return;
    }
    destroySession(key);
    await interaction.reply("PAL sudah keluar dari voice channel.");
    return;
  }

  if (!interaction.member?.voice?.channel) {
    await interaction.reply({ content: "Masuk ke voice channel dulu, lalu jalankan `/musik gabung` lagi.", ephemeral: true });
    return;
  }

  await interaction.reply("PAL sedang mencoba masuk ke voice channel.");
  try {
    await connectToVoice(interaction);
    await interaction.followUp("PAL sudah masuk ke voice channel.");
  } catch (error) {
    console.error("Failed to join voice channel:", error);
    await interaction.followUp({ content: `PAL gagal masuk ke voice channel: ${error.message}`, ephemeral: true });
  }
}

export { definition, handle };
