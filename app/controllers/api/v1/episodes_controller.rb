require "open-uri"
require "json"
require "down"
require "google/cloud/storage"
require "google/cloud/speech/v1/speech"

class Api::V1::EpisodesController < Api::V1::BaseController
  before_action :set_episode, only: [:update]
  skip_after_action :verify_authorized, only: [:upload_audio_for_transcription, :download_transcription]

  def create
    @episode = Episode.new(episode_params)
    authorize @episode
    if @episode.save
      head :no_content
    else
      render_error
    end
  end

  def update
    if @episode.update(episode_params)
      head :no_content
    else
      render_error
    end
  end

  # Upload episode's audio to Google Speech-To-Text
  def upload_audio_for_transcription
    puts "IN UPLOAD AUDIO FUNCTION"
    @speakers_number = params[:transcription][:speakers]
    if params[:transcription][:ep_id] === nil
      puts "EPISODE DOESN'T EXIST"
      @episode = Episode.new(episode_params)
      if @episode.save
        puts "EPISODE CREATED"
        final_transcription = get_transcription()
        puts "EPISODE TRANSCRIPTED"
        @episode.transcription = final_transcription
        if @episode.save
          puts "EPISODE SAVED"
          render json: { message: "Transcription saved" }
        else
          puts "EPISODE SAVE ERROR"
          render_error
        end
      else
        render_error
      end
    else
      puts "EPISODE EXISTS"
      @episode = Episode.find(params[:transcription][:ep_id])
      final_transcription = get_transcription()
      @episode.transcription = final_transcription
      if @episode.save
        render json: { message: "Transcription saved" }
      else
        render_error
      end
    end
  end

  private

  def set_episode
    @episode = Episode.find(params[:id])
    authorize @episode
  end

  def episode_params
    params.require(:episode).permit(:podcast_id, :guid, :title, :summary, :show_notes, :transcription, :podcast_title, enclosure: [:length, :type, :url, :duration, :pubDate], cover_image: [:link, :title, :url])
  end

  def transcription_params
    params.require(:transcription).permit(:speakers, :ep_id)
  end

  def render_error
    render json: { errors: @episode.errors.full_messages },
      status: :unprocessable_entity
  end

  def parse_transcription(input)
    speaker = nil
    terms = []
    time_start = 0
    time_end = nil
    final = []
    res = ""

    def to_min(sec)
      mm, ss = sec.divmod(60)
    end

    def format_time(time)
      if time <= 60
        return "00:#{time <= 9 ? "0" : ""}#{time}"
      else
        t = to_min(time)
        return "#{t[0] <= 9 ? "0" : ""}#{t[0]}:#{t[1] <= 9 ? "0" : ""}#{t[1]}"
      end
    end

    input.each_with_index do |item, i|
      if speaker === nil
        speaker = item.speaker_tag
        terms << item.word
        time_end = item.end_time.seconds
        if i === (input.length - 1)
          ind = "<h4 id='transcript-speaker'>Speaker #{speaker}</h4><p id='transcript-timestamp'>#{format_time(time_start)} - #{format_time(time_end)}</p><p id='transcript-content'>#{terms.join(" ")}</p>"
          res = res + ind
        end
      else
        if item.speaker_tag === speaker
          terms << item.word
          time_end = item.end_time.seconds
          if i === (input.length - 1)
            ind = "<h4 id='transcript-speaker'>Speaker #{speaker}</h4><p id='transcript-timestamp'>#{format_time(time_start)} - #{format_time(time_end)}</p><p id='transcript-content'>#{terms.join(" ")}</p>"
            res = res + ind
          end
        else
          ind = "<h4 id='transcript-speaker'>Speaker #{speaker}</h4><p id='transcript-timestamp'>#{format_time(time_start)} - #{format_time(time_end)}</p><p id='transcript-content'>#{terms.join(" ")}</p>"
          res = res + ind
          speaker = item.speaker_tag
          time_start = item.start_time.seconds
          terms = []
          terms << item.word
          time_end = item.end_time.seconds
        end
      end
    end
    return res
  end

  def get_transcription
    puts "IN GET TRANSCRIPTION FUNCTION"

    speech = ::Google::Cloud::Speech::V1::Speech::Client.new do |config|
      config.credentials = JSON.parse(ENV["GOOGLE_APPLICATION_CREDENTIALS"])
    end

    puts "INIT NEW GOOGLE SPEECH"

    creds = Google::Cloud::Storage::Credentials.new JSON.parse(ENV["GOOGLE_APPLICATION_CREDENTIALS"])

    storage = Google::Cloud::Storage.new(
      project_id: ENV["CLOUD_PROJECT_ID"],
      credentials: creds,
    )
    puts "INIT NEW GOOGLE STORAGE"

    bucket_name = "podwii-audio-source"
    bucket = storage.bucket bucket_name, skip_lookup: true
    puts "FOUND BUCKET"

    config = { language_code: "en-US",
              model: "video",
              enable_automatic_punctuation: true,
              diarization_config: {
      "enable_speaker_diarization": true,
      "max_speaker_count": @speakers_number,
      "min_speaker_count": @speakers_number,
    } }

    url = "https://flex.acast.com/www.scientificamerican.com/podcast/podcast.mp3?fileId=2A1EE68D-18E6-4E3B-BB1FA3C50BE5E395"
    dl_file_name = "#{SecureRandom.urlsafe_base64}"
    dl_file_ext = "#{File.extname(url)}"
    tempfile = Down.download(url, destination: "./tmp/audiotrans/#{dl_file_name}#{dl_file_ext}")
    
    system("ffmpeg -i ./tmp/audiotrans/#{dl_file_name}#{dl_file_ext} -ac 1 ./tmp/audiotrans/#{dl_file_name}.flac")
    FileUtils.rm "./tmp/audiotrans/#{dl_file_name}#{dl_file_ext}"
    file = bucket.create_file "./tmp/audiotrans/#{dl_file_name}.flac", "#{dl_file_name}.flac"
    FileUtils.rm "./tmp/audiotrans/#{dl_file_name}.flac"
    
    puts "UPLOADED TO GOOGLE STORAGE: #{file.name}"
    audio = { uri: "gs://#{bucket_name}/#{dl_file_name}.flac" }

    operation = speech.long_running_recognize config: config, audio: audio
    puts "OPERATION STARTED"
    operation.wait_until_done!
    raise operation.results.message if operation.error?
    results = operation.response.results
    puts "OPERATION RESULTS RECEIVED"
    final_transcription = parse_transcription(results.last.alternatives.first.words)
    file.delete
    return final_transcription

    # if !results.empty?
    #   alternatives = results.first.alternatives
    #   alternatives.each do |alternative|
    #     puts "Transcription: #{alternative.transcript}"
    #   end
    # end
  end
end
