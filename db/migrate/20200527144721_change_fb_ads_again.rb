class ChangeFbAdsAgain < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_ads, :fb_errors, :string
  end
end
