class ChangeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :shop_domain, :string
    add_index :products, :shop_domain
  end
end
