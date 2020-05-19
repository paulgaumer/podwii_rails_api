class AddIntegrationsToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :facebook_app_id, :string
    add_column :podcasts, :financial_support, :string
  end
end
