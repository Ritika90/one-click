class AddCurrencyExchangeToAdsets < ActiveRecord::Migration[5.2]
  def change
    add_column :adsets, :currency_exchange_rate, :string, default: "1"
  end
end
