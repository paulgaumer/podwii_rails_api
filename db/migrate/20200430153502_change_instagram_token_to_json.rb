class ChangeInstagramTokenToJson < ActiveRecord::Migration[6.0]
  def change
    remove_column :podcasts, :instagram_access_token
    add_column :podcasts, :instagram_access_token, :json
  end
end
