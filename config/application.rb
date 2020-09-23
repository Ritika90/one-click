require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Productify
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.assets.enabled = true

    config.middleware.use(Rack::Tracker) do
      handler :facebook_pixel, { id: ENV['FB_PIXEL_ID'] }
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_mailer.default_url_options = { :host=> "http://localhost:3000" }
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                  587,
      domain:               'esferasoft.com',
      user_name:            'ritika@esferasoft.com',
      password:             'xE7a=n3fpt',
      authentication:       'plain',
      enable_starttls_auto: true,
      openssl_verify_mode: 'none'   }
  end
end
