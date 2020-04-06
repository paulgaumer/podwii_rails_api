class AddFeedUrlToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :feed_url, :string
  end
end
