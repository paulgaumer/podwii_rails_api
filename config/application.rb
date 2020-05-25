require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PodcastsApi
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.active_job.queue_adapter = :sidekiq
    config.eager_load_paths += %W(#{config.root}/lib)

    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*",
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          expose: ["Authorization"]
      end
    end

    # For Sentry Debugging Add-on
    Raven.configure do |config|
      config.dsn = "https://d8c9488638394af2a8d712e6261120d6:3787a11f56424049ab4942be928e683d@o392685.ingest.sentry.io/5240621"
    end
    config.filter_parameters << :password

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
