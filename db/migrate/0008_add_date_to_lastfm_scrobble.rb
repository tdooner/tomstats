class AddDateToLastfmScrobble < ActiveRecord::Migration[5.0]
  change_table :lastfm_scrobbles do |t|
    t.date :date
  end

  # backfill based on previous implementation of FitnessActivity#date:
  say('Backfilling', true)
  LastfmScrobble.find_each(batch_size: 1) do |scrobble|
    scrobble.save
  end
end
