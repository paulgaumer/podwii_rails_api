class CreateEpisodes < ActiveRecord::Migration[6.0]
  def change
    create_table :episodes do |t|
      t.string :title
      t.text :show_notes
      t.text :content
      t.string :audio_file
      t.string :pubDate

      t.timestamps
    end
  end
end
