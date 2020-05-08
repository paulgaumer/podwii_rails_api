class CreateThemes < ActiveRecord::Migration[6.0]
  def change
    create_table :themes do |t|
      t.json :colors
      t.references :podcast, null: false, foreign_key: true

      t.timestamps
    end
  end
end
