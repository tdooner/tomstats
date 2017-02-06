require 'json'

module Builder
  class DateHistogram < Base
    DEFAULT_OUTPUT = File.expand_path('../../../build/data/date_histogram.json', __FILE__)

    def calculate
      @data = [
        DailySpreadsheetEntry,
        FitnessActivity,
        GarminDump,
        LastfmScrobble,
        PhoneUsageHistory,
      ].each_with_object({}) do |model, hash|
        hash[model.table_name] = model.last_365_days.group(:date).count
      end
    end
  end
end
