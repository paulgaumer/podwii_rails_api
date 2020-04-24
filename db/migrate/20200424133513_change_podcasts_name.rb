class ChangePodcastsName < ActiveRecord::Migration[6.0]
  def change
    rename_column :podcasts, :name, :title
  end
end
