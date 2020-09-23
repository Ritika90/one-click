class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.integer :product_id
      t.string :store_product_id
      t.string :added_to_store_date
      t.boolean :is_deleted, null: false, default: false
      t.boolean :is_hidden, null: false, default: false

      t.timestamps
    end
  end
end
