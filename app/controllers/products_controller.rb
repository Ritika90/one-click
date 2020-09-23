require 'will_paginate/array'
class ProductsController < AuthenticatedController
	before_action :get_products, only: [:show, :create, :create_fb_ad]
	before_action :get_free_products, only: [:my_products, :index]
	before_action :get_standard_products, only: [:my_products, :index]
	before_action :get_premium_products, only: [:my_products, :index]
	before_action :get_in_review_products, only: [:my_products, :index]

	def index
		@shop_domain = ShopifyAPI::Shop.current.myshopify_domain
		@current_shop = Shop.where(shopify_domain: @shop_domain)

		@recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.current

		# MANAGING SPECIAL OFFERS

		special_offers_list = {"moonrock-bling.myshopify.com" => {"trial_days" => 99, "price" => "1.00"},
    		"pamelas-suggestions.myshopify.com" => {"trial_days" => 21, "price" => "20.00"},
    		"knight-collection.myshopify.com" => {"trial_days" => 99, "price" => "1.00"},
    		"beststorenow2020.myshopify.com" => {"trial_days" => 21, "price" => "20.00"},
    		"inspire-the-world-apparel.myshopify.com" => {"trial_days" => 99, "price" => "1.00"},
    		"core-aestheticz.myshopify.com" => {"trial_days" => 45, "price" => "20.00"},
    		"inovagadgets-com.myshopify.com" => {"trial_days" => 90, "price" => "20.00"},
    		"jasenac.myshopify.com" => {"trial_days" => 99, "price" => "1.00"}}


        if special_offers_list.key?(@shop_domain)
        	pp "Special billing present"
        	trial_days = special_offers_list[@shop_domain]["trial_days"]
        	price = special_offers_list[@shop_domain]["price"]

        	if !@recurring_application_charge or 
        		@recurring_application_charge.trial_days != trial_days or 
        		@recurring_application_charge.price != price
        		

        		pp "Different billing for shop:" + @shop_domain
        		billing_setup(price.to_i, trial_days, 0, @current_shop)
        	else
        		pp "no changes, no new billing needed"
        	end
        end



		if !@recurring_application_charge
			puts "No charge"

			trial_days = 14
			if Product.where(shop_domain: @shop_domain).first.present?
				pp "ProductsPresent - no free trial"
				trial_days = 0
			end

            price = 20.00
            capped_amount = 0

            billing_setup(price, trial_days, capped_amount, @current_shop)
        end

        if @recurring_application_charge
        	if @recurring_application_charge.price == "50.00"
        		if !@current_shop.last.premium
        			puts "Updating to Premium"
        			@current_shop.last.update(premium: true)

        			text = "Content: " + "\n"
				    text = text + "Store name:  " + @shop_domain + "\n"
				    text = text + "Upgraded on: " + @recurring_application_charge.attributes["activated_on"] #+ "\n"
				    # text = text + "Email Address: " + @shop_domain 

				   	# TODO: change this to be for/to the correct email addreses.

				    RestClient.post "https://api:key-b61036acda892d9a6a50672913c0dde3"\
				      "@api.mailgun.net/v3/mg.tannerblumer.com/messages",
				      :from => "One Click E-Com <mailgun@mg.tannerblumer.com>",
				      :to => "campus.martius.software@gmail.com, tanner@mg.tannerblumer.com",
				      :subject => "Store Upgraded",
				      :text => text
        		end
        	end
        end


        # if there is a recurring charge (which there is now)
        # check if the FT length is equal to 

        # list of special offers {shop_domain => {"trial_days" => 60, "price" => 20}}
        # if name in list

        	# if trial_days != @recurring_application_charge['trial_days'] || price != 
        		# new billing


		# variables declaration
		@free_products = []
		@standard_products = []
		@premium_products = []

		@free_active = ''
	    @standard_active = ''
	    @premium_active = ''
	    @newest_active = ''
	    @random_active = ''
	    @in_review_active = ''
	    @disabled_condition = ''

	    @free_active_details = 'Polaris-Tabs__Panel--hidden'
	    @standard_active_details = 'Polaris-Tabs__Panel--hidden'
	    @premium_active_details = 'Polaris-Tabs__Panel--hidden'
	    @in_review_active_details = 'Polaris-Tabs__Panel--hidden'

	    # setting pagination params
	    page = params[:page].present? ? params[:page].to_i : 1
    	@per_page = params[:per_page].present? ? params[:per_page].to_i : 6
    	@offset = (page.to_i - 1) * @per_page + 1

    	@product_type = params[:type].present? ? params[:type] : 'standard'

    	# getting free products
		if (params[:type].present? && params[:type] == 'free') 
		    @free_products = @get_free.paginate(:page => page, :per_page => @per_page)
		    @free_active = 'Polaris-Tabs__Tab--selected'
		    @free_active_details = ''

		# getting paid products
		# The OR here makes it the default
		elsif (params[:type].present? && params[:type] == 'standard') || !params[:type].present?

			if params[:sort].present? && params[:sort] == "Random"
				@get_standard = @get_standard.shuffle
				@random_active = 'active'
			else	
				@get_standard = @get_standard.sort_by {|e| e["release_date"]}.reverse
				@newest_active = 'active'
			end

	    	@standard_products = @get_standard.select {|d| d["release_date"].to_time.utc <= Time.now.utc}.paginate(:page => page, :per_page => @per_page) 

	    	@standard_active = 'Polaris-Tabs__Tab--selected'
	    	@standard_active_details = ''

	    # getting premium products
	    elsif params[:type].present? && params[:type] == 'premium'

	    	if params[:sort].present? && params[:sort] == "Random"
				@get_premium = @get_premium.shuffle
				@random_active = 'active'
			else	
				@get_premium = @get_premium.sort_by {|e| e["release_date"]}.reverse
				@newest_active = 'active'
			end

	    	@premium_products = @get_premium.select {|d| d["release_date"].to_time.utc <= Time.now.utc}.paginate(:page => page, :per_page => @per_page) 

	    	@premium_active = 'Polaris-Tabs__Tab--selected'
	    	@premium_active_details = ''

	    	if (ENV['SHOW_PREMIUM_UPGRADE'].present? && ENV['SHOW_PREMIUM_UPGRADE'] == 'TRUE' && @current_shop.last.premium == true) 
	    		@disabled_condition = ''
	    	else
	    		@disabled_condition = 'disabled-outer'	
	    	end	

	    # getting premium products
		elsif params[:type].present? && params[:type] == 'in_review'
	    	if params[:sort].present? && params[:sort] == "Random"
				@get_in_review = @get_in_review.shuffle
				@random_active = 'active'
			else	
				@get_in_review = @get_in_review.sort_by {|e| e["release_date"]}.reverse
				@newest_active = 'active'
			end

	    	@in_review_products = @get_in_review.paginate(:page => page, :per_page => @per_page) 
	    	@in_review_active = 'Polaris-Tabs__Tab--selected'
	    	@in_review_active_details = ''
	    end	

	    # getting all collections from store
	    @custom_collections = ShopifyAPI::CustomCollection.find(:all)

	    # TODO: product fix

	    @all_products = Product.where(is_deleted: false, shop_domain: @shop_domain).index_by {|s| s.product_id}

	    respond_to do |format|
	    	format.html
	    	format.js
	    end
	end

	def create
		@shop_domain = ShopifyAPI::Shop.current.myshopify_domain

		images = []
		variants = []
		image = {}

		@product["images"].each do |img|
			images << {"src" => img["url"] }
		end	

		# Search shop_domain

		# TODO: product fix
		check_products = Product.where(product_id: params[:id].to_i, shop_domain: @shop_domain)

		# if check_products.present? && check_products.last.is_deleted == false
		# 	redirect_to my_products_path, notice: "Product Already Added to Store"
		# else
			# pricing = @product["pricing"].present? ? @product["pricing"].delete( "$" ).to_f : ''
			# compare_at_pricing = @product["compare_at_pricing"].present? ? @product["compare_at_pricing"].delete( "$" ).to_f : ''
			# item_cost = @product["item_cost"].present? ? @product["item_cost"].to_f : ''
			# variant = ShopifyAPI::Variant.new(
			#   	:price                => pricing,
			#   	:compare_at_price => compare_at_pricing,
			# )

			# variants << variant
			# product = ShopifyAPI::Product.new(
			# 	:title => @product["title"],
			# 	:body_html =>  @product["product_description"],
			# 	:images => images,
			# 	:variants => variants
			# )

			# product.save

			# inventoryItem = ShopifyAPI::InventoryItem.find(product.variants[0].inventory_item_id)
			# inventoryItem.cost = item_cost
			# inventoryItem.save

			variant_options = {}
			keys = []

			variant_condition_check('color', variant_options)
			variant_condition_check('material', variant_options)
			variant_condition_check('size', variant_options)
			variant_condition_check('style', variant_options)
			variant_condition_check('title', variant_options)

			if variant_options.present?
				variant_options.keys.each_with_index do |option, index|
					if index == 0
						variant_options[option].each do |variant|
							variants << {"option1": variant[:name], "option2": "-", "option3": "-" ,"price": variant[:price]}
						end
					end

					if index == 1
						variant_options[option].each do |variant|
							variants << {"option1": "-", "option2": variant[:name], "option3": "-" ,"price": variant[:price]}
						end
					end

					if index == 2
						variant_options[option].each do |variant|
							variants << {"option1": "-", "option2": "-", "option3": variant[:name] ,"price": variant[:price]}
						end
					end
				end
			end	

			product = ShopifyAPI::Product.new(
				:title => @product["title"],
				:body_html =>  @product["product_description"],
				:images => images,
				:options => variant_options.present? ? variant_options.values.flatten.map { |h| h.slice(:option_type) }.each{|h| h.store(:name, h.delete(:option_type))}.uniq : [],
				:variants => variants
			)

			product.save

			if params["collection_id"] != 'Default'
				collect = ShopifyAPI::Collect.new(product_id: product.id, collection_id: params[:collection_id])

				collect.save
			end	

			premium = false
			if params[:type] == 'premium'
				premium = true
			end
			# TODO: not sure what is going on here
			if check_products.present? && check_products.last.is_deleted == true
				puts "LN 141"
				check_products.last.update(is_deleted: false, store_product_id: product.id, added_to_store_date: Time.now.utc)
			else
				puts "ln 144"
				my_products = Product.new(product_id: params[:id].to_i, store_product_id: product.id, added_to_store_date: Time.now.utc, product_type: params[:type] ||= 'free' , shop_domain: @shop_domain, premium: premium)
				my_products.save
			end

			redirect_to my_products_path, notice: "Product Added to Store"
		# end
	end

	def show
		@shop_domain = ShopifyAPI::Shop.current.myshopify_domain

	    my_shop = Shop.where(shopify_domain: @shop_domain).take

	    if my_shop.fb_uid.nil?
	      @show_facebook_login = true
	      puts "nil"
	    else
	      @show_facebook_login = false
	      puts "not nil"
	    end


		if @product.present?
			@primary_image = @product["images"].select {|s| s["is_primary"] == 1}
			if !@primary_image.present?
				@primary_image = @product["images"].select {|s| s["is_primary"] == 0}
			end

			@primary_video = @product["videos"].select {|s| s["is_primary"] == 1}
			if !@primary_video.present?
				@primary_video = @product["videos"].select {|s| s["is_primary"] == 0}
			end
		end

		@all_images = []
		if @primary_image.present? && @product["images"].present?
			@all_images = @primary_image + @product["images"][1..@product["images"].length - 1]
		end

		@all_videos = []
		if @primary_video.present? && @product["videos"].present?
			@all_videos = @primary_video + @product["videos"][1..@product["videos"].length - 1]
		end

		@custom_collections = ShopifyAPI::CustomCollection.find(:all)

		# TODO:  product fix
		@check_product = Product.where(is_deleted: false, product_id: params[:id].to_i, shop_domain: @shop_domain).last

		@my_products = Product.where(is_deleted: false, shop_domain: @shop_domain).index_by {|p| p.product_id}

		# store_products = ShopifyAPI::Product.find(:all, ids: @my_products.values.pluck(:store_product_id))

		store_products = ShopifyAPI::Product.find(:all, params: { ids: @my_products.values.pluck(:store_product_id).join(',') })

		### FB PIXEL FIRES HERE IN THE PROCESS
			tracker do |t|
		      t.facebook_pixel :track, { type: 'Purchase', options: { value: 100, currency: 'USD' } }
		    end

		#####################################

		@store = {}
		store_products.each do |product|
			@store[product.attributes["id"]] = [] if @store[product.attributes["id"]].nil?
			@store[product.attributes["id"]] << product.attributes
		end
	end

	def destroy
	end

	def remove_product
		@shop_domain = ShopifyAPI::Shop.current.myshopify_domain

		product = Product.where(product_id: params[:id].to_i, shop_domain: @shop_domain).last
		puts "product ID"
		puts params[:id]

		# product_no_filter = Product.where(product_id: params[:id].to_i).last
		# puts "product no filter"
		# if product_no_filter.present?
		# 	puts "no filter present"
		# end

		if product.present?
			puts "Found a valid product"
			begin
				store_product = ShopifyAPI::Product.find(product.store_product_id)
				store_product.destroy
			rescue
				"Product does not exist in store - likely deleted by customer"
			end

			product.update(is_deleted: true)
		else
			puts "No valid product found...ERROR"
		end
		redirect_to my_products_path, notice: "Product Deleted Successfully" 
	end

	def my_products
		@shop_domain = ShopifyAPI::Shop.current.myshopify_domain
		puts @shop_domain

		Shop.check_shop(current_shopify_session)
	    my_shop = Shop.where(shopify_domain: @shop_domain).take

	    if my_shop.fb_uid.nil?
	      @show_facebook_login = true
	    else
	      @show_facebook_login = false
	    end

	    # TODO: add shopify_domain
		@my_products = Product.where(is_deleted: false, shop_domain: @shop_domain)
		@my_products_with_index = @my_products.index_by { |s| s.product_id }

		@my_products.each do |temp_product|
			puts temp_product
			puts temp_product.product_id
			# puts temp_product.attributes

			# puts temp_product[:product_id]
			# puts temp_product[:shop_domain]
			# puts temp_product[:is_deleted]

			puts temp_product.product_id
			puts temp_product.is_deleted
			puts temp_product.shop_domain




		end

		# store_products = ShopifyAPI::Product.find(:all, ids: @my_products.pluck(:store_product_id))
		store_products = ShopifyAPI::Product.find(:all, params: { ids: @my_products.pluck(:store_product_id).join(',') })

		@store = {}
		store_products.each do |product|
			puts "DEBUGGING FOR tojea-store.myshopify.com"
			puts @shop_domain + ":::" + product.attributes["id"].to_s
			@store[product.attributes["id"]] = [] if @store[product.attributes["id"]].nil?
			@store[product.attributes["id"]] << product.attributes
		end

		if @my_products.present?
			puts "my product present"
		    @products = @get_free + @get_standard + @get_premium
		    product_ids = @my_products.sort_by(&:updated_at).reverse.pluck(:product_id)

		    @product_details = []
		    product_ids.each do |p|
		    	@product_details << @products.select {|d| d["id"] == p}#.sort_by {|e| product_ids.index(e['id']) }
		    end	
		end    

		collects = ShopifyAPI::Collect.find(:all)

		@collects = {}
		collects.each do |c|
			@collects[c.attributes["product_id"].to_s] = [] if @collects[c.attributes["product_id"].to_s].nil?
			@collects[c.attributes["product_id"].to_s] << c.attributes["collection_id"]

		end

		collections = ShopifyAPI::CustomCollection.find(:all)
		@collections = {}

		collections.each do |c|
			@collections[c.attributes["id"].to_s] = [] if @collections[c.attributes["id"].to_s].nil?
			@collections[c.attributes["id"].to_s] << c.attributes["title"]
		end
	end

	def make_product_available
		# TODO: product fix
		product = Product.where(product_id: params[:id], shop_domain: @shop_domain).last

		if product.present?
			store_product = ShopifyAPI::Product.find(product.store_product_id)
			store_product.attributes["published_at"] = Time.now.utc
			store_product.save
		end
		redirect_to my_products_path, notice: "Product Availability Updated" 
	end

	def upgrade_to_premium
	end

	def upgrade_premium_package
		@shop_domain = ShopifyAPI::Shop.current.myshopify_domain
		current_shop = Shop.where(shopify_domain: @shop_domain)

		current_charge = ShopifyAPI::RecurringApplicationCharge.current
		current_charge.destroy

		charge = ShopifyAPI::RecurringApplicationCharge.new(
			:name => params[:plan_name], 
			:price => params[:price],
			:return_url => billing_callback_url
		)

		if !Rails.env.production?
            charge.test = true
        else
            puts "in production"

            if !current_shop.present?
            	charge.test = true
            else
            	charge.test = false
            end	
        end

		if charge.save
			# current_shop.last.update(premium: true)
            fullpage_redirect_to charge.confirmation_url
            return
        else
            redirect_to :root
            return
        end
	end
	
	private

	def get_products
		pp "438"
		pp params[:type]
		if params[:type] == 'free'
		    @products = get_free_products

		elsif params[:type] == 'standard'
		    @products = get_standard_products

		elsif params[:type] == 'premium'
		    @products = get_premium_products
		elsif params[:type] == 'in_review'
			pp "HERE447"
			@products = get_in_review_products
		end

		if @products.present?
			pp "HERE452"
			@product = @products.select {|s| s["id"] == params[:id].to_i}[0]

			# pp @products
		end
	end

	def get_free_products
		uri = URI.parse(ENV['PRODUCT_LINK_FREE'])
		res = Net::HTTP.get_response(uri)
	    @get_free = JSON.parse(res.body)["entries"]
	end

	def get_standard_products
		uri = URI.parse(ENV['PRODUCT_LINK_PAID'])
		res = Net::HTTP.get_response(uri)
	    @get_standard = JSON.parse(res.body)["entries"]
	end

	def get_premium_products
		uri = URI.parse(ENV['PRODUCT_LINK_PREMIUM'])
		res = Net::HTTP.get_response(uri)
	    @get_premium = JSON.parse(res.body)["entries"]
	end

	def get_in_review_products
		uri = URI.parse(ENV['PRODUCT_LINK_IN_REVIEW'])
		res = Net::HTTP.get_response(uri)
	    @get_in_review = JSON.parse(res.body)["entries"]
	end


	def billing_setup(price, trial_days, capped_amount, current_shop)
        @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
            name: "Full Product Library",
            price: price,
            trial_days: trial_days
            # capped_amount: capped_amount,
            # terms: "Usage based pricing tiers.  Never pay for more than you use!"
            )

        if !Rails.env.production?
            @recurring_application_charge.test = true
        else
            puts "in production"

            if !current_shop.present?
            	@recurring_application_charge.test = true
            else
            	@recurring_application_charge.test = false
            end	
        end

        @recurring_application_charge.return_url = billing_callback_url

        if @recurring_application_charge.save
            puts "successfully saved the charge! with price: " + price.to_s
            fullpage_redirect_to @recurring_application_charge.confirmation_url
            return
        else
            puts "failed to saved"

            redirect_to :root
            return
        end
        puts "239"
    end

    def variant_condition_check(type, variant_options)

    	if @product["options"].present?
    		variant = @product["options"].select {|e| e['option_type'] == type }
    	end	

    	if variant.present? && variant_options.length < 3
    		variant.each do |v|
    			variant_options[type.capitalize] ||= []
				variant_options[type.capitalize] << { price: v['price'], name: v['name'], option_type: v['option_type']    }
			end	
		end	

		return variant_options
    end
end



