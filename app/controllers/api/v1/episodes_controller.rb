require "open-uri"
require "json"
require "down"
require "google/cloud/speech"

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
    speech = Google::Cloud::Speech.new do |config|
      config.credentials = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    end
    puts "INIT NEW GOOGLE SPEECH"
    config = { language_code: "en-US",
              model: "video",
              enable_automatic_punctuation: true,
              diarization_config: {
      "enable_speaker_diarization": true,
      "max_speaker_count": @speakers_number,
      "min_speaker_count": @speakers_number,
    } }
    audio = { uri: "gs://podwii-audio-files/pod-test.wav" }
    operation = speech.long_running_recognize config, audio
    puts "OPERATION STARTED"
    operation.wait_until_done!
    raise operation.results.message if operation.error?
    results = operation.response.results
    final_transcription = parse_transcription(results.last.alternatives.first.words)
    return final_transcription

    # url = "https://anchor.fm/s/f0fca6c/podcast/play/13417950/sponsor/a1hummk/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2020-05-07%2F17ab44bdfa561174a3c9eca2cb4c6f2a.m4a"
    # tempfile = Down.download(url, destination: "./tmp/tmp/tempaudio/test#{File.extname(url)}")

    # system("ffmpeg -i ./tmp/tempaudio/audio.mp3 ./tmp/tempaudio/pod.flac")
    # FileUtils.rm "./tmp/tempaudio/audio.mp3"

    # if !results.empty?
    #   alternatives = results.first.alternatives
    #   alternatives.each do |alternative|
    #     puts "Transcription: #{alternative.transcript}"
    #   end
    # end
  end
end
