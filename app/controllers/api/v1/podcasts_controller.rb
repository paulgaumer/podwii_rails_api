require "open-uri"

class Api::V1::PodcastsController < Api::V1::BaseController
  before_action :set_podcast, only: [ :show, :update, :destroy ]
  before_action :set_s3_object, only: [:upload_audio_for_transcription]
  skip_after_action :verify_authorized, only: [:upload_audio_for_transcription, :download_transcription]

  # def index
  #   @podcasts = policy_scope(Podcast)
  # end

  # Display the user dashboard
  def show
  end

  def create
    @podcast = podcast.new(podcast_params)
    @podcast.user = current_user
    authorize @podcast
    if @podcast.save
      render :show, status: :created
    else
      render_error
    end
  end

  def update
    if @podcast.update(podcast_params)
      # rendre the existing show.json.jbuilder view
      render :show
    else
      render_error
    end
  end

  def destroy
    @podcast.destroy
  end

  # ********** CUSTOM ************

  # Display the user podcast page
  def landing_page
    @podcast = Podcast.find_by(subdomain: params[:subdomain])
    authorize @podcast
  end

  # Upload episode's audio to S3
  def upload_audio_for_transcription
    upload = @s3_obj.upload_stream do |write_stream|
      IO.copy_stream(URI.open('https://chtbl.com/track/G5EG82/www.buzzsprout.com/740042/2205065-00-on-creating-japan-life-stories-with-paul-gaumer.mp3'), write_stream)
    end
    if upload 
      render json:{ message: "File uploaded"}
    else
      render json:{error: upload.errors}
    end
  end

  def download_transcription
    client = Aws::TranscribeService::Client.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    resp = client.get_transcription_job({
      transcription_job_name: "test_transcribe.mp3-4ec0fca3-7849-41df-96b6-07a793c60f3b"
    })
    status = resp.transcription_job.transcription_job_status

    if status === "COMPLETED"
    render json: {
      transcriptFileUri: resp.transcription_job.transcript.transcript_file_uri,
      redactedTranscriptFileUri: resp.transcription_job.transcript.redacted_transcript_file_uri
    }
    else
      render json: {status: status}
    end

  end

  # ********** END CUSTOM ************

  private

  def set_podcast
    @podcast = Podcast.where(user: current_user).first
    authorize @podcast
  end

  def podcast_params
    params.require(:podcast).permit(:name, :description, :url, :audio_player, :subdomain, :feed_url, :cover_url)
  end

  def render_error
    render json: { errors: @podcast.errors.full_messages },
      status: :unprocessable_entity
  end

  def set_s3_object
    s3 = Aws::S3::Resource.new(region: ENV["AWS_REGION"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])  
    bucket_name = ENV["AWS_BUCKET_NAME"]
    @key= "audio_file.mp3"
    @s3_obj = s3.bucket(bucket_name).object(@key)
  end
end
