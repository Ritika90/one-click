class FbUser < ApplicationRecord
  after_find :fb_session=
  after_find :ad_acct_query=
  after_find :u_query=

  # belongs_to :adset

  # A class method uses self to distinguish from instance methods.
  # It can only be called on the class, not an instance.
  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token

      session = FacebookAds::Session.new(access_token: user.token)
      user_query = FacebookAds::User.get(user.uid, session)

      user.ad_account_id = user_query.adaccounts.first.id
      pp user.ad_account_id
      user.ad_account_name = user_query.adaccounts.first.name
      pp user.ad_account_name
      user.page_id = user_query.accounts.first.id
      pp user.page_id
      user.page_name = user_query.accounts.first.name
      pp user.page_name

      begin
        ad_acct_query = FacebookAds::AdAccount.get(user_query.adaccounts.first.id, 'name', session)

        user.pixel_id = ad_acct_query.adspixels(fields: 'name,id').first.id
        user.pixel_name = ad_acct_query.adspixels(fields: 'name,id').first.name

        pp "PIXEL FOUND FOR FIRST ACCOUNT: " + user_query.adaccounts.first.id
      rescue

        user_query.adaccounts.each do |ad_account|
          begin
            ad_acct_query = FacebookAds::AdAccount.get(ad_account.id, 'name', session)
            user.pixel_id = ad_acct_query.adspixels(fields: 'name,id').first.id
            user.pixel_name = ad_acct_query.adspixels(fields: 'name,id').first.name

            pp "PIXEL FOUND FOR ACCOUNT: " + ad_account.id
            break;
          rescue
            pp "NO PIXEL ON THIS ACCOUNT CONTINUE"
          end
        end
        # BAD - this means no pixel is present

      end

      adset = Adset.new(daily_adset_spend: "5", number_of_adsets: "5", currency_exchange_rate: "1")
      adset.save

      user.adset_id = adset.id
      user.active = 1
      user.save!
    end
  end


  # ###################
  # Facebook ad account
  # ###################

  # Setter
  def ad_acct_query=(ad_account_id = self.ad_account_id)
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    # session = FacebookAds::Session.new(access_token: self.token)
    @ad_acct_query = FacebookAds::AdAccount.get(ad_account_id, 'name', fb_session)
  end
  # Getter
  attr_reader :ad_acct_query


  # #############
  # Facebook user
  # #############

  # Setter
  def u_query=
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    # session = FacebookAds::Session.new(access_token: self.token)
    @u_query = FacebookAds::User.get(self.uid, fb_session)
  end
  # Getter
  attr_reader :u_query


  # ################
  # Facebook session
  # ################

  # Setter
  def fb_session=
    @fb_session = FacebookAds::Session.new(access_token: self.token)
  end
  # Getter
  attr_reader :fb_session

end
