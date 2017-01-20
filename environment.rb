require 'active_record'
require 'date'
require 'dotenv'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require_relative './lib/dropbox_client.rb'
require_relative './lib/garmin_scraper.rb'
require_relative './lib/lastfm_scraper.rb'
require_relative './models/daily_spreadsheet_entry.rb'
require_relative './models/fitness_activity.rb'
require_relative './models/garmin_dump.rb'
require_relative './models/lastfm_scrobble.rb'
require_relative './models/tag_processing_record.rb'

autoload :TagProcessor, 'tag_processor.rb'

Dotenv.load(".env.#{ENV['RAILS_ENV']}", '.env')
