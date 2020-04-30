class AddInstagramTokenToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :instagram_access_token, :string
  end
end
