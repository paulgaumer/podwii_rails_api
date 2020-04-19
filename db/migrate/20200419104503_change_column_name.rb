class ChangeColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :episodes, :content, :transcription
  end
end
