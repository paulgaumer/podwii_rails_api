class AddSpeakersDetailsToEpisodes < ActiveRecord::Migration[6.0]
  def change
    add_column :episodes, :speakers_labels, :json
  end
end
