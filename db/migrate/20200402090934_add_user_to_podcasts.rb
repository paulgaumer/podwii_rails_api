class AddUserToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_reference :podcasts, :user, null: false, foreign_key: true
  end
end
