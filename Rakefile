require_relative './environment.rb'

include ActiveRecord::Tasks

ActiveRecord::Base.configurations = {
  ENV['RAILS_ENV'] || 'development' => { 'url' => ENV['DATABASE_URL'] }
}
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
        next if last_item.data == scrobble
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
        date = if row['Timestamp'].include?(' ')
                 DateTime.strptime(row['Timestamp'], '%m/%d/%Y %T')
               else
                 DateTime.strptime(row['Timestamp'], '%m/%d/%Y')
               end

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

    begin
      Timeout.timeout(30) do
        MessageSender.send_daily_update
      end
    rescue => ex
      puts "Error sending daily update: #{ex.inspect}"
      Raven.capture_exception(ex)
    end

    puts "Imported #{DailySpreadsheetEntry.count - count} entries from daily spreadsheet."
  end

  desc 'Backfill garmin'
  task garmin_backfill: 'db:connect' do
    GarminDump
      .order(:date)
      .pluck(:date)
      .each_cons(2) do |date1, date2|
        # TODO: handle case where the dates are incomplete (have one type of
        # data but not the other)
        GarminDump.create_dumps_for_date(date1.succ...date2)
      end
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
    processor = TagProcessor::Processor.new
    processor.discover_processors('./lib/tag_processor')
    processor.process(logger: Logger.new($stderr))
  end
end

namespace :generate do
  task all: 'db:connect' do
    Builder::DateHistogram.new.tap(&:calculate).tap(&:save)
  end
end

namespace :assets do
  task :precompile do
    puts 'Running rake generate:all...'
    Rake::Task['generate:all'].invoke

    puts 'Compiling webpack...'
    `node_modules/.bin/webpack`
    exit 1 unless $?.exitstatus == 0
  end
end
