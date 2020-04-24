class ChangeEpisodesName < ActiveRecord::Migration[6.0]
  def change
    rename_column :episodes, :audio_file, :enclosure
    add_column :episodes, :cover_image, :string
    add_column :episodes, :podcast_title, :string
  end
end
