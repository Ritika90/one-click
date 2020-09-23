class SessionsController < AuthenticatedController
  def create
    @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    pp @shop_domain + "SessionsController"
    fb_user = FbUser.from_omniauth(request.env['omniauth.auth'])

    puts "FB UID"
    puts fb_user.uid




    # select shop where shopify_domain == @shop_domain
    # my_shop = Shop.where(shopify_domain: @shop_domain)

    my_shop = Shop.where(shopify_domain: @shop_domain).take

    my_shop.fb_uid = fb_user.uid

    # my_shop.fb_uid = nil

    my_shop.save

    puts "MYSHOP UID"
    puts my_shop.fb_uid

    # shop.save

    # session[:user_id] = fb_user.id
    redirect_to settings_path, notice: "Facebook Account Connected!"
    return
  end

  def remove_fb_user

    @shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    my_shop = Shop.where(shopify_domain: @shop_domain).take

    my_shop.fb_uid = nil

    my_shop.save
    
    redirect_to settings_path
    return
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

  private

  def fb_user_params
    params.require(:fb_user).permit(
      :uid,
      # This:
      # info: [
      #   :name,
      #   :email
      # ],
      # And this, are the same:
      info: %i[name email],
      # credentials: [
      #   :token
      # ]
      credentials: %i[token]
    )
  end
end
