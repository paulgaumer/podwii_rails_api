class AddGuidToEpisodes < ActiveRecord::Migration[6.0]
  def change
    add_column :episodes, :guid, :string, null: false
    add_column :episodes, :summary, :text
  end
end
