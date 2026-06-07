if (process.env.NODE_ENV !== "production") {
  await import("dotenv/config");
}

const token = process.env.DISCORD_BOT_TOKEN;
const clientId = process.env.DISCORD_CLIENT_ID;

if (!token || !clientId) {
  throw new Error("DISCORD_BOT_TOKEN dan DISCORD_CLIENT_ID wajib diisi.");
}

const guildId = process.env.DISCORD_GUILD_ID || null;

export { token, clientId, guildId };
