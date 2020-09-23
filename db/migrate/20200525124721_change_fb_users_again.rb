class ChangeFbUsersAgain < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_users, :pixel_name, :string
    add_column :fb_users, :ad_account_name, :string
    add_column :fb_users, :page_name, :string
  end
end
