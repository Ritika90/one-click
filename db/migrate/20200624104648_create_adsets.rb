class CreateAdsets < ActiveRecord::Migration[5.2]
  def change
    create_table :adsets do |t|
      t.string :daily_adset_spend
      t.string :number_of_adsets

      t.timestamps
    end
  end
end
