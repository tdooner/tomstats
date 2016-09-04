require 'active_record'
require 'date'
require 'dotenv'

require_relative './lib/dropbox_client.rb'
require_relative './lib/garmin_scraper.rb'
require_relative './models/fitness_activity.rb'
require_relative './models/garmin_dump.rb'

Dotenv.load
