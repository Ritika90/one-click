class ChangeShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :fb_uid, :string
    add_index :shops, :fb_uid, unique: true
  end
end
