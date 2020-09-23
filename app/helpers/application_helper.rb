module ApplicationHelper
	def current_shop
		shop_domain = ShopifyAPI::Shop.current.myshopify_domain
	    my_shop = Shop.where(shopify_domain: shop_domain).take

	    return my_shop
	end
end
