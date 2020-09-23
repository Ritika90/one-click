class ChangeFbUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :fb_users, :url
    add_column :fb_users, :pixel_id, :string
  end
end
