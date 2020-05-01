class ChangeEpsiodeToJson < ActiveRecord::Migration[6.0]
  def change
    remove_column :episodes, :enclosure
    remove_column :episodes, :cover_image

    add_column :episodes, :enclosure, :json
    add_column :episodes, :cover_image, :json
  end
end
