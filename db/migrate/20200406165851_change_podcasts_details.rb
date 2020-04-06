class ChangePodcastsDetails < ActiveRecord::Migration[6.0]
  def change
    change_column :podcasts, :description, :text, :default => "" 
    change_column :podcasts, :feed_url, :string, :default => "" 
    change_column :podcasts, :cover_url, :string, :default => "" 
  end
end
