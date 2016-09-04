class CreateGarminDump < ActiveRecord::Migration[5.0]
  create_table :garmin_dumps do |t|
    t.date :date
    t.string :dump_type, null: false
    t.json :data
  end
end
