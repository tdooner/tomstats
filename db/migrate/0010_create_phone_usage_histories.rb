class CreatePhoneUsageHistories < ActiveRecord::Migration[5.0]
  create_table :phone_usage_histories do |t|
    t.string :name, null: false
    t.date :date, null: false
    t.time :time, null: false
    t.column :duration, :interval, null: false
  end
end
