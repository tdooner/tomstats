class CreateLastfmScrobbles < ActiveRecord::Migration[5.0]
  create_table :lastfm_scrobbles do |t|
    t.integer :timestamp, null: false
    t.json :data

    t.index :timestamp
  end
end
