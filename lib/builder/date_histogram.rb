require 'json'

module Builder
  class DateHistogram
    DEFAULT_OUTPUT = File.expand_path('../../../build/date_histogram.json', __FILE__)

    def self.build(output = DEFAULT_OUTPUT)
      File.open(output, 'w') do |f|
        f.puts(JSON.pretty_generate(
          [
            DailySpreadsheetEntry,
            FitnessActivity,
            GarminDump,
            LastfmScrobble,
          ].each_with_object({}) do |model, hash|
            hash[model.table_name] = model.last_365_days.group(:date).count
          end
        ))
      end
    end
  end
end
