import {
  AudioPlayerStatus,
  NoSubscriberBehavior,
  VoiceConnectionStatus,
  createAudioPlayer,
  createAudioResource,
  entersState,
  joinVoiceChannel,
} from "@discordjs/voice";
import { resolveYouTubeAudio } from "./resolver.js";

const IDLE_TIMEOUT_MS = 5 * 60 * 1000;

const connections = new Map();
const sessions = new Map();

function findSession(key) {
  return sessions.get(key) ?? null;
}

function getSession(key) {
  const existing = sessions.get(key);
  if (existing) return existing;

  const player = createAudioPlayer({
    behaviors: { noSubscriber: NoSubscriberBehavior.Play },
  });

  const session = { current: null, player, queue: [], idleTimer: null };

  player.on("error", (error) => {
    console.error("Audio player error:", error);
    session.current = null;
    playNext(key).catch((err) => console.error("Failed to continue queue after error:", err));
  });

  player.on(AudioPlayerStatus.Idle, () => {
    session.current = null;
    playNext(key).catch((err) => console.error("Failed to continue queue:", err));
  });

  sessions.set(key, session);
  return session;
}

function getConnection(key) {
  return connections.get(key) ?? null;
}

function scheduleIdleDisconnect(key, session) {
  clearTimeout(session.idleTimer);
  session.idleTimer = setTimeout(() => {
    const s = sessions.get(key);
    if (s && !s.current && s.queue.length === 0) {
      destroySession(key);
    }
  }, IDLE_TIMEOUT_MS);
}

async function connectToVoice(interaction) {
  const voiceChannel = interaction.member?.voice?.channel;
  if (!voiceChannel) {
    throw new Error("Masuk ke voice channel dulu, lalu jalankan command lagi.");
  }

  const permissions = voiceChannel.permissionsFor(interaction.guild.members.me);
  if (!permissions?.has("Connect") || !permissions?.has("Speak")) {
    throw new Error("PAL tidak punya izin untuk masuk atau berbicara di voice channel tersebut.");
  }

  const key = interaction.guildId;
  const existing = connections.get(key);
  if (existing) return existing;

  const connection = joinVoiceChannel({
    channelId: voiceChannel.id,
    guildId: interaction.guildId,
    adapterCreator: interaction.guild.voiceAdapterCreator,
    selfDeaf: false,
  });

  await entersState(connection, VoiceConnectionStatus.Ready, 20_000);
  connections.set(key, connection);

  connection.on(VoiceConnectionStatus.Disconnected, () => {
    connections.delete(key);
    const session = sessions.get(key);
    if (session) {
      clearTimeout(session.idleTimer);
      session.queue = [];
      session.current = null;
      session.player.stop(true);
      sessions.delete(key);
    }
  });

  return connection;
}

async function playNext(key) {
  const session = sessions.get(key);
  const connection = connections.get(key);

  if (!session || !connection || session.current || session.queue.length === 0) {
    if (session && !session.current && session.queue.length === 0) {
      scheduleIdleDisconnect(key, session);
    }
    return;
  }

  clearTimeout(session.idleTimer);
  session.idleTimer = null;

  const track = session.queue.shift();
  session.current = track;

  try {
    const audioUrl = await resolveYouTubeAudio(track.url);
    const resource = createAudioResource(audioUrl);
    connection.subscribe(session.player);
    session.player.play(resource);
    await track.interaction.followUp(`PAL mulai memutar audio. Sisa antrean: ${session.queue.length}.`);
  } catch (error) {
    console.error("Failed to play queued YouTube audio:", error);
    session.current = null;
    await track.interaction.followUp(`Gagal memutar audio: ${error.message}`);
    await playNext(key);
  }
}

function destroySession(key) {
  const session = sessions.get(key);
  if (session) {
    clearTimeout(session.idleTimer);
    session.queue = [];
    session.current = null;
    session.player.stop(true);
    sessions.delete(key);
  }
  const connection = connections.get(key);
  if (connection) {
    connection.destroy();
    connections.delete(key);
  }
}

export { findSession, getSession, getConnection, connectToVoice, playNext, destroySession };
