import { SlashCommandBuilder } from "discord.js";
import { findSession } from "../voice/manager.js";

const definition = new SlashCommandBuilder()
  .setName("stop")
  .setDescription("Hentikan audio yang sedang diputar PAL.")
  .toJSON();

async function handle(interaction) {
  const session = findSession(interaction.guildId);
  if (!session || (!session.current && session.queue.length === 0)) {
    await interaction.reply({ content: "Tidak ada audio yang sedang diputar.", ephemeral: true });
    return;
  }

  session.queue = [];
  session.current = null;
  session.player.stop(true);
  await interaction.reply("Playback PAL sudah dihentikan dan antrean dikosongkan.");
}

export { definition, handle };
