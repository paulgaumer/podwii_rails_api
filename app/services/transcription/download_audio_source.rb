require "open-uri"

class Transcription::DownloadAudioSource
  def self.call(src)
    url = src
    puts "DECLARED URL"
    dl_file_name = "#{SecureRandom.urlsafe_base64}"
    puts "DECLARED DL_FILE_NAME: #{dl_file_name}"

    ext = "#{File.extname(url)}"
    # Get rid of parameters
    dl_file_ext = ext.include?("?") ? ext.split("?").first : ext
    puts "DECLARED DL_FILE_EXT: #{dl_file_ext}"

    audio_src = "#{dl_file_name}#{dl_file_ext}"

    download = open(url)
    puts "OPENED URL"
    Rails.root.join("tmp").to_s
    puts "CREATED TMP FOLDER"
    IO.copy_stream(download, "./tmp/#{audio_src}")
    puts "DOWNLOADED SOURCE AUDIO: #{audio_src}"
    return audio_src
  end
end
