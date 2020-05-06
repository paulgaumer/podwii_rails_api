class CreateCrmItems < ActiveRecord::Migration[6.0]
  def change
    create_table :crm_items do |t|
      t.string :email
      t.datetime :date
      t.references :podcast, null: false, foreign_key: true

      t.timestamps
    end
  end
end
