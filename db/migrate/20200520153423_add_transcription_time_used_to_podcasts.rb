class AddTranscriptionTimeUsedToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :transcription_time_used, :integer, default: 0
  end
end
