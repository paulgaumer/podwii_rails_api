class AddSocialsToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :socials, :json
  end
end
