class AddSubdomainToPodcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :podcasts, :subdomain, :string
  end
end
