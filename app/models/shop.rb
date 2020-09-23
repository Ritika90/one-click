# frozen_string_literal: true
class Shop < ActiveRecord::Base
  include ShopifyApp::ShopSessionStorage

  def api_version
    ShopifyApp.configuration.api_version
  end

  def self.check_shop(current_shopify_session)
  	@shop = Shop.where(shopify_domain: current_shopify_session.domain, shopify_token: current_shopify_session.token).last
  	if !@shop.present?
  		Shop.create(shopify_domain: current_shopify_session.domain, shopify_token: current_shopify_session.token)
  		@shop = Shop.where(shopify_domain: current_shopify_session.domain, shopify_token: current_shopify_session.token).last
  	end	
  end

end
