class ChangePodcasts < ActiveRecord::Migration[6.0]
  def change
    change_column :podcasts, :name, :string, :default => ""  
  end
end
