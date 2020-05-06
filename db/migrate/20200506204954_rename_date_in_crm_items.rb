class RenameDateInCrmItems < ActiveRecord::Migration[6.0]
  def change
    rename_column :crm_items, :date, :optin_date
  end
end
