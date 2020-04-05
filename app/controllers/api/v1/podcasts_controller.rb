class Api::V1::PodcastsController < Api::V1::BaseController
  before_action :set_podcast, only: [ :show, :update, :destroy ]

  # def index
  #   @podcasts = policy_scope(Podcast)
  # end

  def show
  end

  def landing_page
    @podcast = Podcast.find_by(subdomain: params[:subdomain])
    authorize @podcast
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

  private

  def set_podcast
    @podcast = Podcast.where(user: current_user).first
    authorize @podcast
  end

  def podcast_params
    params.require(:podcast).permit(:name, :description, :url, :audio_player, :subdomain)
  end

  def render_error
    render json: { errors: @podcast.errors.full_messages },
      status: :unprocessable_entity
  end
end
