class ChangeAdsetColumnType < ActiveRecord::Migration[5.2]
  	def up
  		change_column :adsets, :daily_adset_spend, 'integer USING CAST(daily_adset_spend AS integer)'
  		change_column :adsets, :number_of_adsets, 'integer USING CAST(number_of_adsets AS integer)'
  	end

  	def down
  		change_column :adsets, :daily_adset_spend, :string
  		change_column :adsets, :number_of_adsets, :string
  	end
end
