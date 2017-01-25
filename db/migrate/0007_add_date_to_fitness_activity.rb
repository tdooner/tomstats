class AddDateToFitnessActivity < ActiveRecord::Migration[5.0]
  change_table :fitness_activities do |t|
    t.date :date
  end

  # backfill based on previous implementation of FitnessActivity#date:
  FitnessActivity.find_each(batch_size: 1) do |activity|
    say("Backfilling #{activity.id}", true)
    activity.save
  end
end
