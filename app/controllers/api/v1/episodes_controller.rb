require "open-uri"
require "json"
require "down"
require "google/cloud/speech"

class Api::V1::EpisodesController < Api::V1::BaseController
  before_action :set_episode, only: [:update]
  # before_action :set_s3_resource, only: [:upload_audio_for_transcription]
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

  # Upload episode's audio to S3
  def upload_audio_for_transcription
    # obj_url = nil
    # @key= "TranscriptionJobTestAudio.mp3"
    # @s3_obj = @s3.bucket(@bucket_name).object(@key)
    # upload = @s3_obj.upload_stream do |write_stream|
    #   IO.copy_stream(URI.open('https://podwii-transcripts.s3.eu-west-2.amazonaws.com/pod-test.mp3'), write_stream)
    # end
    # if upload
    #   client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])

    #   settings = {}
    #   if @speakers > 1
    #     settings = {
    #       show_speaker_labels: true,
    #       max_speaker_labels: @speakers,
    #     }
    #   end

    #   resp = client.start_transcription_job({
    #     transcription_job_name: @key, # required
    #     language_code: "en-US", # required
    #     media: { # required
    #       media_file_uri: "s3://#{@bucket_name}/#{@key}",
    #     },
    #     settings: settings,
    #     })
    #   status = resp.transcription_job.transcription_job_status
    #   render json:{ status: status, transcription_job_name: @key}
    # else
    #   render json:{error: upload.errors}
    # end

    @speakers_number = params[:transcription][:speakers]
    speech = Google::Cloud::Speech.new
    config = { language_code: "en-US",
              model: "video",
              enable_automatic_punctuation: true,
              diarization_config: {
      "enable_speaker_diarization": true,
      "max_speaker_count": @speakers_number,
      "min_speaker_count": @speakers_number,
    } }
    audio = { uri: "gs://podwii-audio-files/pod-test.wav" }

    # url = "https://anchor.fm/s/f0fca6c/podcast/play/13417950/sponsor/a1hummk/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2020-05-07%2F17ab44bdfa561174a3c9eca2cb4c6f2a.m4a"
    # tempfile = Down.download(url, destination: "./tmp/tmp/tempaudio/test#{File.extname(url)}")

    # system("ffmpeg -i ./tmp/tempaudio/audio.mp3 ./tmp/tempaudio/pod.flac")
    # FileUtils.rm "./tmp/tempaudio/audio.mp3"

    operation = speech.long_running_recognize config, audio

    puts "OPERATION STARTED"

    operation.wait_until_done!

    raise operation.results.message if operation.error?

    results = operation.response.results

    p results

    results.each do |result|
      out = parse_transcription(result.alternatives.first.words)
      p out
    end

    # output_one = parse_transcription(results.first.alternatives.first.words)
    # p output_one
    # output_two = parse_transcription(results.last.alternatives.first.words)
    # p output_two

    # if !results.empty?
    #   alternatives = results.first.alternatives
    #   alternatives.each do |alternative|
    #     puts "Transcription: #{alternative.transcript}"
    #   end
    # end
  end

  # Retrieve transcription from AWS Transcribe
  # def download_transcription
  #   client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  #   resp = client.get_transcription_job({
  #     transcription_job_name: "TranscriptionJobTestAudio.mp3",
  #   })
  #   status = resp.transcription_job.transcription_job_status
  #   if status === "COMPLETED"
  #     transcription_serialized = URI.open(resp.transcription_job.transcript.transcript_file_uri).read
  #     transcription_file = JSON.parse(transcription_serialized)
  #     transcript = transcription_file["results"]["transcripts"][0]["transcript"]
  #     render json: {
  #       status: status,
  #       transcript: transcript,
  #     }
  #   else
  #     render json: { status: status }
  #   end
  # end

  private

  def set_episode
    @episode = Episode.find(params[:id])
    authorize @episode
  end

  def episode_params
    params.require(:episode).permit(:podcast_id, :guid, :title, :summary, :show_notes, :transcription, :podcast_title, enclosure: [:length, :type, :url, :duration, :pubDate], cover_image: [:link, :title, :url])
  end

  def transcription_params
    params.require(:transcription).permit(:speakers)
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
      # binding.pry
      if time <= 60
        return "00:#{time <= 9 ? "0" : ""}#{time}"
      else
        t = to_min(time)
        return "#{t[0] <= 9 ? "0" : ""}#{t[0]}:#{t[1] <= 9 ? "0" : ""}#{t[1]}"
      end
    end

    input.each_with_index do |item, i|
      # binding.pry
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

  # Need for audio upload to S3
  # def set_s3_resource
  #   @s3 = Aws::S3::Resource.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  #   @bucket_name = ENV["AWS_BUCKET_NAME"]
  # end
end
