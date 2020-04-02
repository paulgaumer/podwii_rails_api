class CreatePodcasts < ActiveRecord::Migration[6.0]
  def change
    create_table :podcasts do |t|
      t.string :name
      t.text :description
      t.text :audio_player
      t.string :url

      t.timestamps
    end
  end
end
