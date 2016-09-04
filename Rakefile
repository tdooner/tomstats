require 'active_record'
require 'date'
include ActiveRecord::Tasks

DatabaseTasks.database_configuration = Hash.new(url: ENV['DATABASE_URL'])
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths = 'db/migrate'

require_relative './lib/dropbox_client.rb'
require_relative './lib/garmin_scraper.rb'
require_relative './models/fitness_activity.rb'
require_relative './models/garmin_dump.rb'

namespace :db do
  task :connect do
    ActiveRecord::Base.establish_connection
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
      FitnessActivity
        .where(dropbox_rev: file.rev)
        .first_or_create
    end
  end

  desc 'Sync garmin activities -> postgres'
  task garmin: 'db:connect' do
    yesterday = Date.today - 1
    garmin = GarminScraper.new(ENV['GARMIN_USERNAME'], ENV['GARMIN_PASSWORD'])
    puts 'Logging into Garmin Connect...'
    garmin.login

    puts '  Downloading sleep data...'
    sleep_data = garmin.sleep_schedule_json(yesterday)
    GarminDump
      .where(dump_type: 'sleep_schedule', date: yesterday)
      .first_or_create
      .update_attribute(:data, sleep_data)

    puts '  Downloading wellness data...'
    wellness = garmin.wellness(yesterday)
    GarminDump
      .where(dump_type: 'wellness', date: yesterday)
      .first_or_create
      .update_attribute(:data, wellness)
  end
end
