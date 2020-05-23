class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      # Needed for Warden and getting a token back!
      sign_up(resource_name, resource)
      Rails.logger.info("Just created and saved #{resource}")
      p = Podcast.new(user: resource)
      p.subdomain = params[:subdomain]
      p.themes.new(colors: { "primary" => "#F97F7F", "headerText" => "#D17C78", "headerBackground" => "#181D46", "activeTheme" => "theme1" })
      if p.save
        render json: { message: "User & Podcast created" }
      else
        resource.destroy
        render json: { errors: p.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      render json: { errors: resource.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  # # Notice the name of the method
  def sign_up_params
    params.require(:user).permit(:email, :password)
  end
end
