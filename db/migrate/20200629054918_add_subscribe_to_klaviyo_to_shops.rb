class AddSubscribeToKlaviyoToShops < ActiveRecord::Migration[5.2]
  def up
    add_column :shops, :subscribe_to_klaviyo, :boolean, default: false, null: false
  end

  def down
    remove_column :shops, :subscribe_to_klaviyo, :boolean, default: false, null: false
  end
end
