import { readdirSync } from "node:fs";
import { Client, GatewayIntentBits, REST, Routes } from "discord.js";
import { token, clientId, guildId } from "./config.js";

const COMMAND_HANDLERS = new Map();
const commandDefinitions = [];

for (const file of readdirSync(new URL("./commands", import.meta.url)).filter((f) => f.endsWith(".js"))) {
  const mod = await import(`./commands/${file}`);
  COMMAND_HANDLERS.set(mod.definition.name, mod.handle);
  commandDefinitions.push(mod.definition);
}

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildVoiceStates],
});

async function registerCommands() {
  const rest = new REST({ version: "10" }).setToken(token);

  if (guildId) {
    await rest.put(Routes.applicationGuildCommands(clientId, guildId), { body: commandDefinitions });
    return;
  }
  await rest.put(Routes.applicationCommands(clientId), { body: commandDefinitions });
}

client.once("clientReady", () => {
  console.log(`PAL is online as ${client.user.tag}`);
});

client.on("interactionCreate", async (interaction) => {
  if (!interaction.isChatInputCommand()) return;

  const handle = COMMAND_HANDLERS.get(interaction.commandName);
  if (!handle) return;

  try {
    await handle(interaction);
  } catch (error) {
    console.error(`Failed to handle /${interaction.commandName}:`, error);
    const message = { content: "Maaf, PAL gagal menjalankan command itu.", ephemeral: true };
    if (interaction.replied || interaction.deferred) {
      await interaction.followUp(message);
    } else {
      await interaction.reply(message);
    }
  }
});

process.on("unhandledRejection", (reason) => {
  console.error("Unhandled promise rejection:", reason);
});

process.on("uncaughtException", (error) => {
  console.error("Uncaught exception:", error);
  process.exit(1);
});

try {
  await registerCommands();
  await client.login(token);
} catch (error) {
  console.error("Failed to start PAL:", error);
  process.exit(1);
}
