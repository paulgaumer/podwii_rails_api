require "open-uri"
require "json"

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
    obj_url = nil
    @speakers = params[:transcription][:speakers]
    @key= "TranscriptionJobTestAudio.mp3"
    @s3_obj = @s3.bucket(@bucket_name).object(@key)
    upload = @s3_obj.upload_stream do |write_stream|
      IO.copy_stream(URI.open('https://podwii-transcripts.s3.eu-west-2.amazonaws.com/pod-test.mp3'), write_stream)
    end
    if upload
      obj_url = @s3.bucket(@bucket_name).object(@key).public_url
    
      client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    binding.pry

      resp = client.start_transcription_job({
        transcription_job_name: @key, # required
        language_code: "en-US", # required, accepts en-US, es-US, en-AU, fr-CA, en-GB, de-DE, pt-BR, fr-FR, it-IT, ko-KR, es-ES, en-IN, hi-IN, ar-SA, ru-RU, zh-CN, nl-NL, id-ID, ta-IN, fa-IR, en-IE, en-AB, en-WL, pt-PT, te-IN, tr-TR, de-CH, he-IL, ms-MY, ja-JP, ar-AE
        media: { # required
          media_file_uri: "s3://#{@bucket_name}/#{@key}",
        },
        settings: {
          show_speaker_labels: true,
          max_speaker_labels: @speakers,
        },
        content_redaction: {
          redaction_type: "PII", # required, accepts PII
          redaction_output: "redacted", # required, accepts redacted, redacted_and_unredacted
        },
      })
      status = resp.transcription_job.transcription_job_status
      render json:{ status: status, transcription_job_name: @key}
    else
      render json:{error: upload.errors}
    end
  end

  # Retrieve transcription from AWS Transcribe
  def download_transcription
    client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    resp = client.get_transcription_job({
      transcription_job_name: "test_transcribe.mp3-4ec0fca3-7849-41df-96b6-07a793c60f3b"
    })
    status = resp.transcription_job.transcription_job_status

    if status === "COMPLETED"
      transcription_serialized = URI.open(resp.transcription_job.transcript.transcript_file_uri).read
      transcription_file = JSON.parse(transcription_serialized)
      transcript = transcription_file["results"]["transcripts"][0]["transcript"]
      render json: {
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
    params.require(:episode).permit(:podcast_id, :guid, :title, :summary, :show_notes, :transcription, :enclosure, :cover_image, :podcast_title)
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
