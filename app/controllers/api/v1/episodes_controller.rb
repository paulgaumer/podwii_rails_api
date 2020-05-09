require "open-uri"
require "json"
require "down"
require "google/cloud/speech"


class Api::V1::EpisodesController < Api::V1::BaseController
  before_action :set_episode, only: [ :update ]
  before_action :set_s3_resource, only: [:upload_audio_for_transcription]
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
    # @speakers = params[:transcription][:speakers]
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

    speech = Google::Cloud::Speech.new
    config = { language_code:     "en-US",
                model: "video",
                diarization_config: {
                  "enable_speaker_diarization": true,
                  "min_speaker_count": 2,
                  "max_speaker_count": 2,
                }
              }
    # audiomp3 = { uri: "gs://podwii-audio-files/pod-test.mp3"}
    
    url = "https://anchor.fm/s/f0fca6c/podcast/play/13417950/sponsor/a1hummk/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2020-05-07%2F17ab44bdfa561174a3c9eca2cb4c6f2a.m4a"
    tempfile = Down.download(url, destination: "./tempaudio/test#{File.extname(url)}")
    
    binding.pry
    

    system("ffmpeg -i ./tempaudio/audio.mp3 ./tempaudio/pod.flac")
    FileUtils.rm "./tempaudio/audio.mp3"

    operation = speech.long_running_recognize config, audio

    puts "OPERATION STARTED"

    p operation

    operation.wait_until_done!

    raise operation.results.message if operation.error?

    results = operation.response.results

    p results

    if !results.empty?
      alternatives = results.first.alternatives
      alternatives.each do |alternative|
        puts "Transcription: #{alternative.transcript}"
      end
    end


  end

  # Retrieve transcription from AWS Transcribe
  def download_transcription
    client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    resp = client.get_transcription_job({
      transcription_job_name: "TranscriptionJobTestAudio.mp3"
    })
    status = resp.transcription_job.transcription_job_status
    if status === "COMPLETED"
      transcription_serialized = URI.open(resp.transcription_job.transcript.transcript_file_uri).read
      transcription_file = JSON.parse(transcription_serialized)
      transcript = transcription_file["results"]["transcripts"][0]["transcript"]
      render json: {
        status: status,
        transcript: transcript
      }
    else
      render json: {status: status}
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
    params.require(:transcription).permit(:speakers)
  end

  def render_error
    render json: { errors: @episode.errors.full_messages },
      status: :unprocessable_entity
  end

  # Need for audio upload to S3
  def set_s3_resource
    @s3 = Aws::S3::Resource.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])  
    @bucket_name = ENV["AWS_BUCKET_NAME"]
  end

end
