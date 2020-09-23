class CreateFbAds < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_ads do |t|
      t.string :uid
      t.string :campaign_name
      t.string :interests
      t.integer :gender
      t.string :headline
      t.text :ptext
      t.string :video_url
      t.string :thumbnail_url
      t.string :video_id
      t.string :pixel_id
      t.string :countries
      t.string :creative_id
      t.string :campaign_id
      t.string :ad_set_id
      t.string :ad_id
      t.integer :result
      t.string :result_status
      t.datetime :start_time

      t.timestamps
    end
  end
end
