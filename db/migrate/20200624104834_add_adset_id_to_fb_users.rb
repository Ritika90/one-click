class AddAdsetIdToFbUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_users, :adset_id, :integer
  end
end
