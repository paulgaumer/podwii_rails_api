class Api::V1::ThemesController < Api::V1::BaseController
before_action :set_theme, only: [ :update ]

def update
  if @theme.update(theme_params)
      head :no_content
    else
      render_error
    end
end

private

  def theme_params
    params.require(:theme).permit(colors: [:primary])
  end

  def set_theme
    @theme = Theme.find(params[:id])
    authorize @theme
  end

  def render_error
      render json: { errors: @theme.errors.full_messages },
      status: :unprocessable_entity
  end

end
