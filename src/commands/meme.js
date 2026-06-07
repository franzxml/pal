import { SlashCommandBuilder } from "discord.js";

const MEME_URLS = [
  "https://i.imgflip.com/30b1gx.jpg",
  "https://i.imgflip.com/1bij.jpg",
  "https://i.imgflip.com/26am.jpg",
  "https://i.imgflip.com/1otk96.jpg",
  "https://i.imgflip.com/3si4.jpg",
  "https://i.imgflip.com/4t0m5.jpg",
];

const definition = new SlashCommandBuilder()
  .setName("meme")
  .setDescription("Kirim meme acak ke kanal ini.")
  .toJSON();

async function handle(interaction) {
  const index = Math.floor(Math.random() * MEME_URLS.length);
  await interaction.reply(MEME_URLS[index]);
}

export { definition, handle };
