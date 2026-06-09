import { MessageFlags, SlashCommandBuilder } from "discord.js";
import { stopPlayback } from "../voice/manager.js";

const definition = new SlashCommandBuilder()
  .setName("stop")
  .setDescription("Hentikan audio yang sedang diputar PAL.")
  .toJSON();

async function handle(interaction) {
  if (!stopPlayback(interaction.guildId)) {
    await interaction.reply({ content: "Tidak ada audio yang sedang diputar.", flags: MessageFlags.Ephemeral });
    return;
  }

  await interaction.reply("Playback PAL sudah dihentikan dan antrean dikosongkan.");
}

export { definition, handle };
