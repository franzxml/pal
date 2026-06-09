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
const READY_TIMEOUT_MS = 20_000;
const RECONNECT_GRACE_MS = 5_000;

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

function cleanupSession(key) {
  const session = sessions.get(key);
  if (!session) return;
  clearTimeout(session.idleTimer);
  session.queue = [];
  session.current = null;
  session.player.stop(true);
  sessions.delete(key);
}

function registerConnectionHandlers(key, connection) {
  connection.on(VoiceConnectionStatus.Disconnected, async () => {
    // Disconnected bisa bersifat sementara (misal bot dipindah channel).
    // Beri waktu singkat untuk pulih; jika tidak, hancurkan koneksi.
    try {
      await Promise.race([
        entersState(connection, VoiceConnectionStatus.Signalling, RECONNECT_GRACE_MS),
        entersState(connection, VoiceConnectionStatus.Connecting, RECONNECT_GRACE_MS),
      ]);
    } catch (error) {
      console.error("Voice connection did not recover, destroying:", error);
      if (connection.state.status !== VoiceConnectionStatus.Destroyed) {
        connection.destroy();
      }
    }
  });

  connection.on(VoiceConnectionStatus.Destroyed, () => {
    connections.delete(key);
    cleanupSession(key);
  });
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

  try {
    await entersState(connection, VoiceConnectionStatus.Ready, READY_TIMEOUT_MS);
  } catch (error) {
    if (connection.state.status !== VoiceConnectionStatus.Destroyed) {
      connection.destroy();
    }
    throw new Error("PAL tidak berhasil tersambung ke voice channel. Coba lagi.", { cause: error });
  }

  // joinVoiceChannel mengembalikan koneksi yang sama untuk guild yang sama,
  // jadi pemanggilan bersamaan tidak boleh mendaftarkan handler dua kali.
  if (!connections.has(key)) {
    connections.set(key, connection);
    registerConnectionHandlers(key, connection);
    scheduleIdleDisconnect(key, getSession(key));
  }

  return connection;
}

async function notifyTrack(track, content) {
  // Token interaction kedaluwarsa setelah 15 menit; kegagalan notifikasi
  // tidak boleh menghentikan antrean.
  try {
    await track.interaction.followUp(content);
  } catch (error) {
    console.error("Failed to send queue notification:", error);
  }
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
  } catch (error) {
    console.error("Failed to play queued YouTube audio:", error);
    session.current = null;
    await notifyTrack(track, `Gagal memutar audio: ${error.message}`);
    await playNext(key);
    return;
  }

  await notifyTrack(track, `PAL mulai memutar audio. Sisa antrean: ${session.queue.length}.`);
}

function stopPlayback(key) {
  const session = sessions.get(key);
  if (!session || (!session.current && session.queue.length === 0)) {
    return false;
  }

  session.queue = [];
  session.current = null;
  session.player.stop(true);
  scheduleIdleDisconnect(key, session);
  return true;
}

function destroySession(key) {
  cleanupSession(key);
  const connection = connections.get(key);
  connections.delete(key);
  if (connection && connection.state.status !== VoiceConnectionStatus.Destroyed) {
    connection.destroy();
  }
}

export { findSession, getSession, getConnection, connectToVoice, playNext, stopPlayback, destroySession };
