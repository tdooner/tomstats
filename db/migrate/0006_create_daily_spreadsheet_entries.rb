class CreateDailySpreadsheetEntries < ActiveRecord::Migration[5.0]
  create_table :daily_spreadsheet_entries do |t|
    t.date :date
    t.string :entry_type
    t.string :value
  end
end
