require 'active_record'
require 'date'
require 'dotenv'

require_relative './lib/dropbox_client.rb'
require_relative './lib/garmin_scraper.rb'
require_relative './lib/lastfm_scraper.rb'
require_relative './models/fitness_activity.rb'
require_relative './models/garmin_dump.rb'
require_relative './models/lastfm_scrobble.rb'
require_relative './models/tag_processing_record.rb'
require_relative './lib/tag_processor/base.rb'
require_relative './lib/tag_processor/activity_type.rb'
require_relative './lib/tag_processor/activity_start_end.rb'
require_relative './lib/tag_processor.rb'

Dotenv.load
