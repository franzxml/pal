import { SlashCommandBuilder } from "discord.js";
import { randomMeme } from "../meme-catalog.js";

const definition = new SlashCommandBuilder()
  .setName("meme")
  .setDescription("Kirim meme acak ke kanal ini.")
  .toJSON();

async function handle(interaction) {
  await interaction.reply(randomMeme());
}

export { definition, handle };
