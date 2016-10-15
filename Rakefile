require_relative './environment.rb'

include ActiveRecord::Tasks

DatabaseTasks.database_configuration = Hash.new('url' => ENV['DATABASE_URL'])
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths = 'db/migrate'

namespace :db do
  task :connect do
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end

  task console: :connect do
    require 'pry'
    binding.pry
  end

  desc 'Create database'
  task :create do
    DatabaseTasks.create_current(ENV['RAILS_ENV'] || 'development')
  end

  desc 'Migrate database'
  task migrate: :connect do
    require 'zlib' # Needed by ActiveRecord for some reason
    DatabaseTasks.migrate
  end
end

namespace :sync do
  desc 'Sync dropbox fitness activities -> postgres'
  task dropbox: 'db:connect' do
    dropbox = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
    dropbox.list_directory('/Apps/tapiriik').each do |file|
      activity = FitnessActivity
        .where(dropbox_rev: file.rev)
        .first_or_create

      if activity.data.blank?
        activity.update_attribute(:data, file.download)
      end
    end
  end

  desc 'Sync garmin activities -> postgres'
  task garmin: 'db:connect' do
    yesterday = Date.today - 1
    GarminDump.create_dumps_for_date(yesterday)
  end

  desc 'Sync lastfm -> postgres'
  task lastfm: 'db:connect' do
    last_item = LastfmScrobble.order(timestamp: :desc).first
    created = 0
    LastfmScraper
      .new(ENV['LASTFM_API_KEY'])
      .each_scrobble(from: last_item.timestamp) do |scrobble|
        next if scrobble.fetch('@attr', {})['nowplaying']
        created += 1
        LastfmScrobble.where(
          timestamp: scrobble['date']['uts'].to_i,
        ).first_or_create(
          data: scrobble
        )
      end

    puts "Downloaded #{created} scrobbles."
  end

  desc 'Sync daily spreadsheet -> postgres'
  task daily: 'db:connect' do
    require 'csv'
    require 'date'
    require 'open-uri'

    count = DailySpreadsheetEntry.count

    open(ENV['DAILY_TRACKING_URL']) do |f|
      CSV.parse(f.read, col_sep: "\t", headers: :first_row) do |row|
        date = DateTime.strptime(row['Timestamp'], '%m/%d/%Y %T')
        if date.hour <= 12
          date = date - 1
        end

        [
          ['How was today? [Good]', :how_good],
          ['How was today? [Unique]', :how_unique],
          ['How was today? [Productive]', :how_productive],
          ['Who did you hang out with?', :hung_out_with],
          ['How many glasses of alcohol today?', :glasses_alcohol],
        ].each do |col, type|
          entry = DailySpreadsheetEntry
                    .where(date: date.to_date, entry_type: type)
                    .first_or_create
          entry.update_attributes(value: row[col])
        end
      end
    end

    puts "Imported #{DailySpreadsheetEntry.count - count} entries from daily spreadsheet."
  end

  desc 'Backfill garmin'
  task garmin_backfill: 'db:connect' do
    GarminDump.create_dumps_for_date(Date.new(2016, 4, 1)..Date.new(2016, 9, 3))
  end

  desc 'Backfill Lastfm'
  task lastfm_backfill: 'db:connect' do
    created = 0

    LastfmScraper
      .new(ENV['LASTFM_API_KEY'])
      .each_scrobble(to: ENV['LASTFM_BACKFILL_TO']) do |scrobble|
        created += 1
        puts scrobble['date']['#text']
        LastfmScrobble.create(
          timestamp: scrobble['date']['uts'].to_i,
          data: scrobble
        )
      end

    puts "Downloaded #{created} scrobbles."
  end
end

namespace :process do
  task tags: 'db:connect' do
    TagProcessor::Processor.new
  end
end
