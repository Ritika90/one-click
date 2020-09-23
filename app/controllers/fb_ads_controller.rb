require 'will_paginate/array'
class FbAdsController < AuthenticatedController
    before_action :get_products, only: [:create_fb_ad]

    def show_ads
        @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
        my_shop = Shop.where(shopify_domain: @shop_domain).take
        # @fb_user = FbUser.where(uid: my_shop.fb_uid).take

        @fb_ads_unsorted = FbAd.where(uid: my_shop.fb_uid).index_by {|s| s.start_time}
        # Newest first
        @fb_ads = @fb_ads_unsorted.sort_by {|k,v| k}.reverse

        # View:
        # campaign_name
        # start_time -> datetime
        # result_status -> processing -> error -> success
        # errors -> if present


        return
    end

    # FB Ad Creation
    def create_fb_ad

        @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
        puts @shop_domain + "CREATE_FB_AD"

        rails_product = Product.where(product_id: @product['id'].to_i, shop_domain: @shop_domain).take

        store_product = ShopifyAPI::Product.find(rails_product.store_product_id)

        store_product_url = ShopifyAPI::Shop.current.domain + "/products/" + store_product.handle
        pp store_product_url


        @fb_ad = create_fb_ad_from_product(@product, store_product_url)

        # Video stuff
        video_url = get_video_from_product(@product)
        video = {
            name: @product['title'] + "Video #{Random.rand(300)}",
            file_url: video_url
        }
        
        begin
            created_video = @fb_user.ad_acct_query.advideos.create(video)
            @fb_ad.video_id = created_video.id
            @fb_ad.video_url = video["file_url"]
        rescue FacebookAds::ClientError => e
            pp e
            puts "Error - ln 45"




            @fb_ad.update({
                fb_errors: e.error_user_title,
                result_status: "ERROR"
            })
            # 
            # TODO: Add error to @fb_ad and save it!!!!!
            # 





            redirect_to show_ads_path
            return
        end

        puts "line 43"
        @fb_ad.save

        puts "Line 46"

        Thread.new do
            puts "In new thread"
            20.times do

                # TODO: change timing here (3-10 seconds)
                sleep(4)
                puts "slept"
            end
            puts "DONE SLEEPING"

            run_fb_ad(@fb_ad, @shop_domain)
        end

        redirect_to show_ads_path, notice: "Facebook Ad Created - Please wait 5 minutes for visibility"
        return
    end


    # private


    def run_fb_ad(fb_ad, shop_domain)
        my_shop = Shop.where(shopify_domain: shop_domain).take
        @fb_user = FbUser.where(uid: my_shop.fb_uid).take
        currency_exchange_rate = Adset.find_by_id(@fb_user.adset_id).currency_exchange_rate

        pp "currency_exchange_rate"
        pp currency_exchange_rate
        @ad_acct_query = @fb_user.ad_acct_query

        pp shop_domain + "create FB Add"

        ###### Get Number of daily_adset_spend ##########
            daily_budget = 10
            if @fb_user.present? && @fb_user.adset_id.present?
                @fb_adset = Adset.find_by_id(@fb_user.adset_id)

                daily_budget = @fb_adset.daily_adset_spend
            end
        pp "DAILY BUDGET:::"
        pp daily_budget
        #################################################    

        hardcoded = {
            adset_name: 'Test',
            objective: 'CONVERSIONS',
            status: 'ACTIVE',
            call_to_action: "SHOP_NOW",
            age_min: 21,
            age_max: 65,
            daily_budget: daily_budget.to_i # dollars
        }

        ad_creative = {
            name: "My Creative #{Random.rand(300)}",
            object_story_spec: {
                page_id: @fb_user.page_id,
                video_data: {
                    video_id: fb_ad.video_id,
                    image_url: fb_ad.thumbnail_url,
                    title: fb_ad.headline,
                    message: fb_ad.ptext,
                    call_to_action: {
                        type: hardcoded[:call_to_action],
                        value: {
                            link: fb_ad.url
                        }
                    }
                }
            }
        }
        begin
            created_ad_creative = @ad_acct_query.adcreatives.create(ad_creative)
        rescue FacebookAds::ClientError => e



            fb_ad.update({
                fb_errors: e.error_user_title,
                result_status: "ERROR"
            })
            # 
            # TODO: Add error to @fb_ad and save it!!!!!
            # 




            # redirect_to settings_path, notice: e.error_user_title
            return
        end

        campaign = {
            name: fb_ad.campaign_name,
            objective: hardcoded[:objective],
            special_ad_category: 'NONE',
            status: 'PAUSED',
        }

        begin
            created_campaign = @ad_acct_query.campaigns.create(campaign)
        rescue FacebookAds::ClientError => e
            created_ad_creative.destroy





            fb_ad.update({
                fb_errors: e.error_user_title,
                result_status: "ERROR"
            })
            # 
            # TODO: Add error to @fb_ad and save it!!!!!
            # 



            # redirect_to settings_path, notice: e.error_user_title
            return
        end

        my_adsets = []
        my_ads = []

        my_errors = []

        targeting = {
            age_max: hardcoded[:age_max],
            age_min: hardcoded[:age_min],
            device_platforms: ['mobile', 'desktop'],
            facebook_positions: ['feed', 'video_feeds'],
            # genders: [@fb_ad.gender],
            geo_locations: {
                countries: fb_ad.countries,
                location_types: ['home', 'recent'],
            },
            instagram_positions: ['stream'],
            # TODO: what is this?
            locales: [24,6],
            publisher_platforms: ['facebook', 'instagram'],
            targeting_optimization: 'none'
        }

        adset = {
            status: hardcoded[:status],
            start_time: fb_ad.start_time,
            campaign_id: created_campaign.id,
            targeting: targeting,
            optimization_goal: 'OFFSITE_CONVERSIONS',
            billing_event: 'IMPRESSIONS',
            bid_strategy: 'LOWEST_COST_WITHOUT_CAP',
            daily_budget: hardcoded[:daily_budget] * 100 * currency_exchange_rate.to_i,
            pacing_type: ['standard'],
            destination_type: 'WEBSITE',
            attribution_spec: [
                { event_type: 'CLICK_THROUGH', window_days: 7 },
                { event_type: 'VIEW_THROUGH', window_days: 1 }
            ],
            promoted_object: {
                pixel_id: @fb_user.pixel_id,
                custom_event_type: 'PURCHASE'
            }
        }




        interests = fb_ad.interests.each do |int|
            retrieved_adset = FacebookAds::AdsInterest.get(int, 'name', @fb_user.fb_session)
            adset[:name] = retrieved_adset.name
            adset[:targeting][:flexible_spec] = [ {
                interests: [{ id: int, name: retrieved_adset.name }]
            } ]

            begin
                created_adset = @ad_acct_query.adsets.create(adset)
                pp ""
                pp created_adset
                pp ""
            rescue FacebookAds::ClientError => e
                pp "line260"
                pp e

                my_errors.push(e.error_user_title)
                next
            end

            ad = {
                name: retrieved_adset.name,
                adset_id: created_adset.id,
                status: hardcoded[:status],
                creative: {
                    creative_id: created_ad_creative.id
                },
                tracking_specs: [ {
                    # We're using the old hash notation because symbols can't use `.`.
                    "action.type" => ['offsite_conversion'],
                    :fb_pixel => [@fb_user.pixel_id]
                } ]
            }

            begin
                created_ad = @ad_acct_query.ads.create(ad)
                pp ""
                pp created_ad
                pp ""

                my_ads.push(created_ad.id)
                my_adsets.push(created_adset.id)
            rescue FacebookAds::ClientError => e
                pp "line290"
                pp e
                my_errors.push(e.error_user_title)
                created_adset.destroy
            end
        end


        pp ""
        pp my_errors
        pp ""



        # This will depend upon what really goes on in the above - what failures and why do we see them here?
        # This might only be a few one-off failures due to bad interests...
        # We could base it on how many failures VS how many successful ads
        # 
        # fb_ad.update({
        #     fb_errors: e.error_user_title,
        #     result_status: "ERROR"
        # })
        # 
        # TODO: Add error to @fb_ad and save it!!!!!
        # 





        pp "Adsets:"
        pp my_adsets

        pp "My Ads:"
        pp my_ads



        puts "YOLO"

        
        if my_errors.empty?
            puts 'Fb ad was successfully created.'
            fb_ad.update({
                creative_id: created_ad_creative.id,
                campaign_id: created_campaign.id,
                ad_set_id: my_adsets,
                ad_id: my_ads,
                result: 1,
                result_status: "Success"
            })
        else
            puts "FAILURE" + @shop_domain

            error_message = ""
            if not my_errors.first.nil?
                error_message = my_errors.first
            end

            fb_ad.update({
                creative_id: created_ad_creative.id,
                campaign_id: created_campaign.id,
                ad_set_id: my_adsets,
                ad_id: my_ads,
                result: 1,
                result_status: "FAILURE" + error_message
            })
        end
        # return nil
    end


    # TODO: implement
    def get_video_from_product(product)
        pp "261"
        # loop through videos and find primary = true or 1
        video_url = product['videos'][0]['url']
        product['videos'].each do |video|
            pp video
            if video['is_primary'] == 1
                video_url = video['url']
                pp video_url.gsub!(/\s/,'%20')
                return video_url
            end
        end
        pp video_url.gsub!(/\s/,'%20')
        return video_url
    end

    def create_fb_ad_from_product(product, product_url)
        @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
        my_shop = Shop.where(shopify_domain: @shop_domain).take
        @fb_user = FbUser.where(uid: my_shop.fb_uid).take

        @fb_ad = FbAd.new

        @fb_ad.result_status = "Processing"

        # :uid
        @fb_ad.uid = my_shop.fb_uid

        # :campaign_name
            # item name + day and month?
        @fb_ad.campaign_name = product['title']

        # :gender
            # do not set, defaults to all

        # :headline
            # ad_headline
        @fb_ad.headline = product['ad_headline']

        # :ptext
            # ad_copy
        @fb_ad.ptext = product['ad_copy']

        # :thumbnail_url
            # "thumbnail"

        @fb_ad.thumbnail_url = product['thumbnail']




        # TODO: implement
        # :interests
            # @interests = @ad_acct_query.targetingsearch({
            #     q: params[:suggestion],
            #     type: 'adinterest',
            #     fields: 'name,id,audience_size'
            # }).first(10)
            # hard


        @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
        my_shop = Shop.where(shopify_domain: @shop_domain).take
        @fb_user = FbUser.where(uid: my_shop.fb_uid).take

        ###### Get Number of Adsets ##########
            if @fb_user.present? && @fb_user.adset_id.present?
                @fb_adset = Adset.find_by_id(@fb_user.adset_id)

                number_of_adsets = @fb_adset.number_of_adsets
            end  
        ######################################

        @ad_acct_query = FacebookAds::AdAccount.get(@fb_user.ad_account_id, 'name', @fb_user.fb_session)


        interests_array = Array.new
        digits = 1..10
        digits.each do |digit|
            begin

                # TODO: error handling incase this isn't present
                product_interest = @product["interest_" + digit.to_s]

                pp "---------PRODUCT INTEREST--------"
                pp product_interest


                @interests = @ad_acct_query.targetingsearch({
                    q: product_interest,
                    type: 'adinterest',
                    fields: 'name,id,audience_size'
                }).first(10)

                winning_interest_id = ""
                winning_interest_name = ""
                largest_audience = 0
                @interests.each do |interest|


                    pp interest
                    # pp interest[:name]
                    # compare interest :name to product_interest
                    if product_interest.casecmp(interest[:name]) == 0
                        if interest[:audience_size] > largest_audience
                            winning_interest_id = interest[:id]
                            winning_interest_name = interest[:name]
                            largest_audience = interest[:audience_size]

                            pp "New winner"
                        end
                    end
                end

                pp winning_interest_name
                pp winning_interest_id
                pp largest_audience.to_s

                if winning_interest_id != ""
                    interests_array.push(winning_interest_id)
                else
                    pp " Line 444"
                end

                # TODO: store winning interest ID in an array
            rescue => e
                pp "There was an error in capturing one of the interests"
                pp e

            end

        end


        ##### sampled interest array on the basis of number_of_adsets #####

            if number_of_adsets.present?
                interests_array = interests_array.sample(number_of_adsets)
            end    

        ###################################################################  

        pp "Interests array:"
        pp interests_array 

        @fb_ad.interests = interests_array

        # :countries
            # only US
        @fb_ad.countries = ["US", "AU", "CA", "GB", "NZ"]

        @fb_ad.url = product_url



        # Time when to publish this ad
        # TODO: update with more accurate numbers
        @fb_ad.uid = @fb_user.uid
        tomorrow = Time::now + 86400
        @fb_ad.start_time = tomorrow
        @fb_ad.end_time = (tomorrow + 604800)

        return @fb_ad

    end

    # def set_ad_acct_query
    #     # @ad_acct_query = FacebookAds::AdAccount.get(current_user.ad_account_id, 'name', current_user.fb_session)
    #     @ad_acct_query = current_user.ad_acct_query
    # end

    # def 




















    def get_products
        if params[:type] == 'free'
            @products = get_free_products

        elsif params[:type] == 'standard'
            @products = get_standard_products

        elsif params[:type] == 'premium'
            @products = get_premium_products
        end

        if @products.present?
            @product = @products.select {|s| s["id"] == params[:id].to_i}[0]
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

end