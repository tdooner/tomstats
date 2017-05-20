class AddIndexToPhoneUsageHistories < ActiveRecord::Migration[5.0]
  def change
    # add a unique index here:
    change_table :phone_usage_histories do |t|
      t.index %i[csv_name name date time],
        unique: true,
        name: :idx_unique_name_and_datetime
    end
  end
end
