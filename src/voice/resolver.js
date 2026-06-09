import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

const ALLOWED_PROTOCOLS = new Set(["http:", "https:"]);

const YOUTUBE_HOSTS = new Set([
  "youtube.com",
  "www.youtube.com",
  "m.youtube.com",
  "music.youtube.com",
  "youtu.be",
]);

const YTDLP_ERROR_PATTERNS = [
  { pattern: /private video/i, message: "Video ini bersifat privat dan tidak bisa diputar." },
  { pattern: /video unavailable/i, message: "Video ini tidak tersedia." },
  { pattern: /has been removed/i, message: "Video ini telah dihapus." },
  { pattern: /age.?restrict/i, message: "Video ini dibatasi usia dan tidak bisa diputar." },
  { pattern: /sign in to confirm your age/i, message: "Video ini memerlukan verifikasi usia." },
  { pattern: /not available in your country/i, message: "Video ini tidak tersedia di region ini (geo-restricted)." },
  { pattern: /members.only/i, message: "Video ini hanya untuk anggota channel tersebut." },
  { pattern: /copyright/i, message: "Video ini diblokir karena masalah hak cipta." },
];

function parseYtDlpError(stderr) {
  for (const { pattern, message } of YTDLP_ERROR_PATTERNS) {
    if (pattern.test(stderr)) return message;
  }
  return "yt-dlp gagal mengambil audio dari video tersebut.";
}

const INVALID_URL_MESSAGE = "URL harus berasal dari YouTube.";

function parseYouTubeUrl(url) {
  let parsed;
  try {
    parsed = new URL(url);
  } catch (error) {
    throw new Error(INVALID_URL_MESSAGE, { cause: error });
  }

  if (!ALLOWED_PROTOCOLS.has(parsed.protocol) || !YOUTUBE_HOSTS.has(parsed.hostname.toLowerCase())) {
    throw new Error(INVALID_URL_MESSAGE);
  }

  return parsed;
}

function validateYouTubeUrl(url) {
  try {
    parseYouTubeUrl(url);
    return true;
  } catch {
    return false;
  }
}

async function resolveYouTubeAudio(url) {
  const parsed = parseYouTubeUrl(url);

  try {
    const { stdout } = await execFileAsync(
      "yt-dlp",
      ["--no-playlist", "--format", "bestaudio/best", "--get-url", parsed.toString()],
      { timeout: 45_000, maxBuffer: 1024 * 1024 },
    );

    const audioUrl = stdout.split("\n").find((line) => line.trim())?.trim();
    if (!audioUrl) {
      throw new Error("yt-dlp tidak mengembalikan URL audio.");
    }

    return audioUrl;
  } catch (error) {
    if (error.message === "yt-dlp tidak mengembalikan URL audio.") throw error;
    throw new Error(parseYtDlpError(error.stderr ?? error.message), { cause: error });
  }
}

export { resolveYouTubeAudio, validateYouTubeUrl };
