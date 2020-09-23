class CreateFbUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_users, id: false do |t|
      t.primary_key :sno
      t.string :uid
      t.string :name
      t.string :email
      t.string :token
      t.string :ad_account_id
      t.string :page_id
      t.string :url
      t.integer :active

      t.timestamps
    end
    add_index :fb_users, :uid, unique: true
  end
end
