class GarminDump < ActiveRecord::Base
  def self.create_dumps_for_date(date)
    garmin = GarminScraper.new(ENV['GARMIN_USERNAME'], ENV['GARMIN_PASSWORD'])
    puts 'Logging into Garmin Connect...'
    garmin.login

    puts '  Downloading sleep data...'
    sleep_data = garmin.sleep_schedule_json(date)
    GarminDump
      .where(dump_type: 'sleep_schedule', date: date)
      .first_or_create
      .update_attribute(:data, sleep_data)

    puts '  Downloading wellness data...'
    wellness = garmin.wellness(date)
    GarminDump
      .where(dump_type: 'wellness', date: date)
      .first_or_create
      .update_attribute(:data, wellness)
  end
end
