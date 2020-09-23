Rails.application.routes.draw do
  # root :to => 'home#index'
  root :to => 'products#index'
  resources :products

  get 'my-products' => 'products#my_products', as: 'my_products' #show the products added to store
  post 'remove_product' => 'products#remove_product', as: 'remove_product' #remove the products from store and my_products page
  get 'make_product_available' => 'products#make_product_available', as: 'make_product_available'  # change product availability

  get 'upgrade_to_premium' => 'products#upgrade_to_premium', as: 'upgrade_to_premium'

  get 'past-campaigns' => 'home#past_campaigns', as: 'past_campaigns'  # showing the past campaigns

  get 'settings' => 'home#settings', as: 'settings'  # display the settings

  # TODO: temp?
  get 'debugging' => 'home#debugging', as: 'debugging'  # display the settings

  post 'update_settings' => 'home#update_settings', as: 'update_settings'
  post 'update_ad_settings' => 'home#update_ad_settings', as: 'update_ad_settings'
  get 'create_fb_ad' => 'fb_ads#create_fb_ad', as: 'create_fb_ad'
  get 'show_fb_ads' => 'fb_ads#show_ads', as: 'show_ads'


  get 'instructions' => 'home#instructions', as: 'instructions'
  get 'contact_us', to: 'home#contact_us'

  # GDPR Webhooks
  post '/gdpr/customers/redact', to: 'gdpr#customers_redact'
  post '/gdpr/shop/redact', to: 'gdpr#shop_redact'
  post '/gdpr/customers/data_request', to: 'gdpr#customers_request'

  get '/billing/callback', to: 'home#callback', as: :billing_callback
  get '/billing/denied', to: 'home#denied', as: :billing_denied



  # Facebook stuff
  # match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get 'remove_fb_user' => 'sessions#remove_fb_user', as: 'remove_fb_user'
  get 'auth/facebook/callback', to: 'sessions#create'
  post 'auth/facebook/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/'), via: [:get, :post]

  # Klaviyo
  post 'track_klaviyo' => 'klaviyo#track', to: 'track_klaviyo'

  get 'upgrade_premium_package' => 'products#upgrade_premium_package', to: 'upgrade_premium_package'

  # Refunds
  post '/refunds' => 'refunds#create', as: 'refunds_create'

  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end


