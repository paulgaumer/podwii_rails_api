class AddDirectoriesToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :directories, :json
  end
end
