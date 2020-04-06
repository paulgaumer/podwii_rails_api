class AddPodcastToEpisodes < ActiveRecord::Migration[6.0]
  def change
    add_reference :episodes, :podcast, null: false, foreign_key: true
  end
end
