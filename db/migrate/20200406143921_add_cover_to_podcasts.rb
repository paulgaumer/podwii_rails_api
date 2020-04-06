class AddCoverToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :cover_url, :string
  end
end
