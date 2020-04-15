require "open-uri"

class Api::V1::PodcastsController < Api::V1::BaseController
  before_action :set_podcast, only: [ :show, :update, :destroy ]
  before_action :set_s3_object, only: [:upload_audio_for_transcription]

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

  def upload_audio_for_transcription
    @s3_obj.upload_stream do |write_stream|
      byebug
      IO.copy_stream(URI.open("https://dwj199mwkel52.cloudfront.net/assets/core/home/coding-school-that-cares-alumni-025e665def0e2f5a9a539cd2f8762fedbd4c5074a725ebed08570a5bdacc45f7.jpg", write_stream))
    end
  end

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
    @s3_obj = s3.bucket(bucket_name)
  end
end
