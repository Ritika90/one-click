# frozen_string_literal: true
Rails.application.config.middleware.use(OmniAuth::Builder) do
# frozen_string_literal: true

provider :shopify,
  ShopifyApp.configuration.api_key,
  ShopifyApp.configuration.secret,
  scope: ShopifyApp.configuration.scope,
  setup: lambda { |env|
    strategy = env['omniauth.strategy']

    shopify_auth_params = strategy.session['shopify.omniauth_params']&.with_indifferent_access
    shop = if shopify_auth_params.present?
      "https://#{shopify_auth_params[:shop]}"
    else
      ''
    end

    strategy.options[:client_options][:site] = shop
    strategy.options[:old_client_secret] = ShopifyApp.configuration.old_secret
    strategy.options[:per_user_permissions] = strategy.session[:user_tokens]
  }


provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
  scope: 'email,manage_pages,ads_management',
  client_options: {
    site: 'https://graph.facebook.com/v6.0',
    authorize_url: "https://www.facebook.com/v6.0/dialog/oauth"
  }
end


