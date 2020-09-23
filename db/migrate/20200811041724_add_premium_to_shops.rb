class AddPremiumToShops < ActiveRecord::Migration[5.2]
  def up
    add_column :shops, :premium, :boolean, null: false, default: false
  end

  def down
    remove_column :shops, :premium, :boolean
  end
end
