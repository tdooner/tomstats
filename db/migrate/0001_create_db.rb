class CreateDb < ActiveRecord::Migration[5.0]
  create_table :fitness_activities do |t|
    t.string :dropbox_rev, null: false
  end
end
