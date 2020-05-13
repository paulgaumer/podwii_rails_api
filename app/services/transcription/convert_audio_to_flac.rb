class Transcription::ConvertAudioToFlac
  def self.call(src)
    src_name = src.split(File.extname(src)).first
    puts "SOURCE:#{src}"
    puts "SOURCE NAME:#{src_name}"
    system("ffmpeg -i ./tmp/#{src} -ac 1 ./tmp/#{src_name}.flac")
    puts "CONVERTED TO FLAC"
    FileUtils.rm "./tmp/#{src}"
    puts "REMOVED SOURCE FILE"
    return "#{src_name}.flac"
  end
end
