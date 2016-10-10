class AddFitnessActivity < ActiveRecord::Migration[5.0]
  change_table :fitness_activities do |t|
    t.text :data
  end
end
