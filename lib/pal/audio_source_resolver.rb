# frozen_string_literal: true

require "open3"
require "uri"

module Pal
  class AudioSourceResolver
    class Error < StandardError; end

    YOUTUBE_HOST_PATTERN = /(^|\.)youtu(be\.com|\.be)\z/.freeze

    def initialize(command: "yt-dlp")
      @command = command
    end

    def resolve(url)
      uri = parse_url(url)
      raise Error, "URL harus berasal dari YouTube." unless youtube_url?(uri)

      stdout, stderr, status = Open3.capture3(
        @command,
        "--no-playlist",
        "--format",
        "bestaudio/best",
        "--get-url",
        uri.to_s
      )

      unless status.success?
        message = stderr.strip.empty? ? "yt-dlp gagal mengambil audio." : stderr.strip
        raise Error, message
      end

      audio_url = stdout.lines.first&.strip
      raise Error, "yt-dlp tidak mengembalikan URL audio." if audio_url.nil? || audio_url.empty?

      audio_url
    rescue Errno::ENOENT
      raise Error, "yt-dlp tidak ditemukan. Install dulu dengan `brew install yt-dlp`."
    end

    private

    def parse_url(url)
      uri = URI.parse(url.to_s.strip)
      raise Error, "URL YouTube tidak valid." unless uri.is_a?(URI::HTTP) && uri.host

      uri
    rescue URI::InvalidURIError
      raise Error, "URL YouTube tidak valid."
    end

    def youtube_url?(uri)
      uri.host.downcase.match?(YOUTUBE_HOST_PATTERN)
    end
  end
end
