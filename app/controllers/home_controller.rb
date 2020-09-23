# frozen_string_literal: true

class HomeController < AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    @webhooks = ShopifyAPI::Webhook.find(:all)
  end

  def past_campaigns
  end

  def debugging
    if request.params["authenticity_token"].present?
      @shop_domain = params["shop_domain"]
      pp "DEBUGGING" + @shop_domain
      @my_shop = Shop.where(shopify_domain: @shop_domain).take
      @fb_user = FbUser.where(uid: @my_shop.fb_uid).take

      @ad_accounts = @fb_user.u_query.adaccounts(fields: 'name,id').map {|a| [a.name, a.id + "," + a.name]}

      @ad_acct_hash = {}
      user_query = FacebookAds::User.get(@fb_user.uid, @fb_user.fb_session)
      user_query.adaccounts.each do |ad_account|
        ad_acct_query = FacebookAds::AdAccount.get(ad_account.id, 'name', @fb_user.fb_session)
        @pixels = ad_acct_query.adspixels(fields: 'name,id')
        if @pixels.first.nil?
          @ad_acct_hash[ad_account.id] = "no_pixels"
        else
          @ad_acct_hash[ad_account.id] = @pixels
        end
      end

      @show_data = true
    else

      @show_data = false
    end
    return
  end

  def settings
    @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    my_shop = Shop.where(shopify_domain: @shop_domain).take

    puts "here" + @shop_domain

    puts my_shop.fb_uid

    if my_shop.fb_uid.nil?
      puts "Fb)uid is null"
      @show_facebook_login = true
    else
      puts "fb uid is present"
      @show_facebook_login = false

      @fb_user = FbUser.where(uid: my_shop.fb_uid).take

      if @fb_user.present? && @fb_user.adset_id.present?
        pp "Adset is present ln 32"
        @fb_adset = Adset.find_by_id(@fb_user.adset_id)
      else
        @fb_adset = false

        # TODO: VERIFY

        # if params[:type] == 'initial' && @show_facebook_login
        #   flash.now[:notice] = 'Please connect your Facebook Account before creating a Facebook Ad'
        # end
        # return
      end


      pp @fb_user

      puts "Ad account ID: "
      puts @fb_user.ad_account_id

      # catch error here and propogate problem: FacebookAds::ClientError
      begin
        @ad_accounts = @fb_user.u_query.adaccounts(fields: 'name,id').map {|a| [a.name, a.id + "," + a.name]}

        # TODO:
        # loop through ad accounts and get all pixels and put in an array or dict
        # dictionary = { "one" => "eins", "two" => "zwei", "three" => "drei" }
        # puts dictionary["one"]

        @ad_accounts = @fb_user.u_query.adaccounts(fields: 'name,id').map {|a| [a.name, a.id + "__" + a.name]}
        pp "ADACCOUNTS:"
        pp @ad_accounts
        @pages = @fb_user.u_query.accounts(fields: 'name,id').map {|p| [p.name, p.id + "," + p.name]}

        @default_ad_account = @fb_user.ad_account_id + "__" + @fb_user.ad_account_name
        @default_ad_account = params[:ad_acct].present? ? params[:ad_acct] : @default_ad_account
        @default_ad_account_name = @fb_user.ad_account_name

        @default_page = @fb_user.page_id + "," + @fb_user.page_name
        @default_page_name = @fb_user.page_name

        if @fb_user.pixel_id.present? && @fb_user.pixel_name.present?
          @default_pixel = @fb_user.pixel_id + "," + @fb_user.pixel_name
          @default_pixel_name = @fb_user.pixel_name
        else
          @default_pixel = " - "
          @default_pixel_name = " - "
        end

      rescue => error
        pp "ERROR_CONNECTING_TO_FB" + @shop_domain
        pp error.message

        flash.now[:notice] = error.message
        my_shop.fb_uid = nil
        my_shop.save
        @show_facebook_login = true
        return
      end
      # @default_pixel = @fb_user.pixel_id + "," + @fb_user.pixel_name
      # @default_pixel_name = @fb_user.pixel_name

      ###############################################################

      ##### New Code###########################




      # @ad_accounts = ["ad_acct1", "ad_acct2", "ad_acct3"]
      @pixels_hash = {}
      @ad_accounts.each do |ad_account|
        pp ad_account
        pp "ln 74"
        ad_account_id = ad_account[1].split("__")[0]
        pp ad_account_id
        ad_account_name = ad_account[1].split('__')[1]
        pp ad_account_name
        ad_acct_query = FacebookAds::AdAccount.get(ad_account_id, 'name', @fb_user.fb_session)
        @pixels = ad_acct_query.adspixels(fields: 'name,id')
        pp @pixels
        if @pixels.first.nil?
          pp "84"
          @pixels_hash[ad_account_id + "__" + ad_account_name] = ["no_pixels","no pixels"]
        else
          pp "87"
          pp @pixels.first
          @pixels_hash[ad_account_id + "__" + ad_account_name] = @pixels.map {|p| [p.name, p.id + "," + p.name]}
        end
      end

      # {"id_name" => }
      # @pixels_hash = { "ad_acct1" =>["pixel1.1","pixel1.2"], "ad_acct2" =>["pixel2.1","pixel2.2", "pixel2.3"], "ad_acct3" =>["pixel3.1"]}

      @final_pixel_hash = @pixels_hash[@default_ad_account]

      pp @default_ad_account
      pp @pixels_hash
      pp @final_pixel_hash

      if @final_pixel_hash.nil?
        pp "final_pixel_hash_NIL" + @shop_domain

        @final_pixel_hash = @pixels_hash.values[0]
        pp "Using backup: " + @final_pixel_hash
      end

      if params[:ad_acct].present?
        @default_pixel = @final_pixel_hash[0]
      end

      if @fb_adset && @fb_adset.currency_exchange_rate != "1"
        @currency_set = true
        @exchange_rate = @fb_adset.currency_exchange_rate.to_i
      else
        @currency_set = false
        @exchange_rate = 1
      end
    end

    if params[:type] == 'initial' && @show_facebook_login
      flash.now[:notice] = 'Please connect your Facebook Account before creating a Facebook Ad'
    end

    # return
  end

  def update_settings
    @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    my_shop = Shop.where(shopify_domain: @shop_domain).take
    @fb_user = FbUser.where(uid: my_shop.fb_uid).take

    puts params

    puts "Params" + @shop_domain
    puts params[:fb_user]
    puts params[:fb_user][:ad_account_id]
    puts params[:fb_user][:page_id]
    puts params[:fb_user][:pixel_id]
    puts "Fuck"

    @fb_user.ad_account_id = params[:fb_user][:ad_account_id].split('__')[0]
    @fb_user.ad_account_name = params[:fb_user][:ad_account_id].split('__')[1]

    @fb_user.page_id = params[:fb_user][:page_id].split(',')[0]
    @fb_user.page_name = params[:fb_user][:page_id].split(',')[1]

    if params[:fb_user][:pixel_id].present?
      @fb_user.pixel_id = params[:fb_user][:pixel_id].split(',')[0]
      @fb_user.pixel_name = params[:fb_user][:pixel_id].split(',')[1]
    end

    pp "Testing this bad boy"
    @fb_user.ad_acct_query = @fb_user.ad_account_id

    @fb_user.save


    redirect_to settings_path, notice: "Settings Updated!"
  end

  def instructions

  end

  def contact_us
    if request.params["authenticity_token"].present?
      puts "its a post!"
      @shop_domain = ShopifyAPI::Shop.current.myshopify_domain

      @my_shop = Shop.where(shopify_domain: @shop_domain).take

      text = "Name: " + params[:txtName] + "\n"
      text = text + "Email: " + params[:txtEmail] + "\n"
      text = text + "Message: " + params[:txtMessage] + "\n"
      text = text + "Store: " + @shop_domain + "\n"
      text = text + "Premium: " + @my_shop.premium.to_s.capitalize


      # TODO: change this to be for/to the correct email addreses.

      RestClient.post "https://api:key-b61036acda892d9a6a50672913c0dde3"\
      "@api.mailgun.net/v3/mg.tannerblumer.com/messages",
      :from => "One Click E-Com <mailgun@mg.tannerblumer.com>",
      :to => "campus.martius.software@gmail.com, tanner@mg.tannerblumer.com",
      :subject => "A Customer Has Contacted You",
      :text => text
      return
    end
  end

  def callback
    puts "got the app charge from charge_IDz"
    @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
    puts "pew"
    @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    puts "got the app charge from charge_ID"
    if @recurring_application_charge.status == 'accepted'

        #  API #1 TODO: -> billing_accepted_register
        #  Increment proxy count, set to installed == true -> only increment proxy count if number of orders all time is == 0
        #  args:  store_name

        # billing_accepted_register({"shop_domain" => @shop_domain})
        # This should assign the proxy and increment it.

        @recurring_application_charge.activate
        puts "We successfully activated a billing"
    else

        puts "Denied billing"
        redirect_to billing_denied_url
        return
    end
    puts "we are about to route to index page"
    redirect_to root_url
    return
  end

  def denied

  end

  def update_ad_settings
    @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    pp "Updating ad sets for " + @shop_domain
    my_shop = Shop.where(shopify_domain: @shop_domain).take
    @fb_user = FbUser.where(uid: my_shop.fb_uid).take

    exchange_rate = "1"
    if not params[:check_currency].nil?
      pp "line222 - check currency is NOT nil"
      exchange_rate = params[:currency_multiple]
    end

    adset = Adset.new(daily_adset_spend: params[:daily_adset_spend], number_of_adsets: params[:number_of_adsets], currency_exchange_rate: exchange_rate)
    




    adset.save

    pp "ln165"
    pp params[:daily_adset_spend]
    pp params[:number_of_adsets]
    pp params[:check_currency] # => "1" when selected, nil when not selected
    pp params[:currency_multiple] # => "2" if value is 2, "1" if not selected

    if @fb_user.present? && adset.present?
      @fb_user.update(adset_id: adset.id)
    end 

    redirect_to settings_path, notice: "Settings Updated!"
  end
end
