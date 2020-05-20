require "json"

class Transcription::GetAudioDuration
  def self.call(src, episode_id)
    src_name = src.split(File.extname(src)).first
    puts "GETTING DURATION"
    system("ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 ./tmp/#{src} > ./tmp/#{src_name}.txt")
    duration = nil
    File.readlines("./tmp/#{src_name}.txt").each do |line|
      duration = line
    end
    puts "DURATION FROM TXT: #{duration}"
    # ep = Episode.find(episode_id)
    # ep.update(duration: duration)
    FileUtils.rm "./tmp/#{src_name}.txt"
    return duration
  end
end
