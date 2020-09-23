class AddPremiumToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :premium, :boolean, null: :false, default: false
  end
end
