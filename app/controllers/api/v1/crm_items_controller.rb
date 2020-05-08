class Api::V1::CrmItemsController < Api::V1::BaseController
before_action :set_podcast, only: [ :create ]

def index
  @crm_items = policy_scope(CrmItem)
  # binding.pry
  render json: {items: @crm_items}
end

def create
  @crm_item = @podcast.crm_items.new(episode_params)
  authorize @crm_item
  if @crm_item.save
      render json: {message: "Item created"}
    else
      render_error
    end
end

private

  def episode_params
    params.require(:crm_item).permit(:email, :podcast_id)
  end

  def set_podcast
    @podcast = Podcast.find(params[:crm_item][:podcast_id])
  end

  def render_error
      render json: { errors: @crm_item.errors.full_messages },
      status: :unprocessable_entity
  end

end
