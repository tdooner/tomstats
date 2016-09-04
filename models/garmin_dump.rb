class GarminDump < ActiveRecord::Base
  def self.create_dumps_for_date(date_or_range)
    garmin = GarminScraper.new(ENV['GARMIN_USERNAME'], ENV['GARMIN_PASSWORD'])
    puts 'Logging into Garmin Connect...'
    garmin.login

    range = date_or_range.is_a?(Range) ? date_or_range : (date_or_range..date_or_range)

    range.each do |date|
      puts "  Downloading sleep data for #{date}..."
      sleep_data = garmin.sleep_schedule_json(date)
      GarminDump
        .where(dump_type: 'sleep_schedule', date: date)
        .first_or_create
        .update_attribute(:data, sleep_data)

      puts "  Downloading wellness data for #{date}..."
      wellness = garmin.wellness(date)
      GarminDump
        .where(dump_type: 'wellness', date: date)
        .first_or_create
        .update_attribute(:data, wellness)
    end
  end
end
