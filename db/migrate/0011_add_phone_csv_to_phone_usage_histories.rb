class AddPhoneCsvToPhoneUsageHistories < ActiveRecord::Migration[5.0]
  change_table :phone_usage_histories do |t|
    t.string :csv_name, null: false
  end
end
