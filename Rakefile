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
    GarminDump.create_dumps_for_date(yesterday)
  end
end
