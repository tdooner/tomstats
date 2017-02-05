require 'json'

module Builder
  class DateHistogram
    DEFAULT_OUTPUT = File.expand_path('../../../build/data/date_histogram.json', __FILE__)

    def initialize
      @data = nil
    end

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

    def to_json
      JSON.pretty_generate(@data)
    end

    def save(output = DEFAULT_OUTPUT)
      File.open(output, 'w') do |f|
        f.puts(self.to_json)
      end
    end
  end
end
