import { SlashCommandBuilder } from "discord.js";
import { findSession } from "../voice/manager.js";

const definition = new SlashCommandBuilder()
  .setName("queue")
  .setDescription("Lihat antrean musik PAL.")
  .toJSON();

async function handle(interaction) {
  const session = findSession(interaction.guildId);
  if (!session || (!session.current && session.queue.length === 0)) {
    await interaction.reply({ content: "Antrean PAL masih kosong.", ephemeral: true });
    return;
  }

  const lines = [];
  if (session.current) {
    lines.push(`Sedang diputar: ${session.current.url}`);
  }

  if (session.queue.length > 0) {
    const queued = session.queue
      .slice(0, 10)
      .map((track, index) => `${index + 1}. ${track.url}`);
    lines.push(`Antrean berikutnya:\n${queued.join("\n")}`);
  } else {
    lines.push("Tidak ada antrean berikutnya.");
  }

  await interaction.reply({ content: lines.join("\n\n"), ephemeral: true });
}

export { definition, handle };
