require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GaultmillauEu
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.active_record.schema_format = :sql
    config.time_zone = 'Budapest'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.default_locale = :en
    config.available_locales = [:en, :hu, :cz, :de, :hr, :ro, :cs, :sl, :sk]

    config.restaurant_images_asset_host = 'http://assets.gaultmillau.hu/system'
  end
end
