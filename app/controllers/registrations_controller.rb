class RegistrationsController < Devise::RegistrationsController
  def create
    super
    if resource.persisted?
      Rails.logger.info("Just created and saved #{resource}")
      p = Podcast.new(user: resource)
      p.subdomain = params[:subdomain]
      p.themes.new()
      p.save!
    end
  end

  # private

  # # Notice the name of the method
  # def sign_up_params
  #   params.require(:user).permit(:email, :password, :password_confirmation)
  # end
end
