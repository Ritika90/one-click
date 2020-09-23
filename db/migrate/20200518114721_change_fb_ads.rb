class ChangeFbAds < ActiveRecord::Migration[5.2]
  def change
    remove_column :fb_ads, :pixel_id
    add_column :fb_ads, :url, :string
    add_column :fb_ads, :end_time, :datetime
  end
end
