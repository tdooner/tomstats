require 'json'

module Builder
  class DateHistogram
    DEFAULT_OUTPUT = File.expand_path('../../../build/date_histogram.json', __FILE__)

    def self.build(output = DEFAULT_OUTPUT)
      File.open(output, 'w') do |f|
        [
          DailySpreadsheetEntry,
          # TODO: enable this
          # FitnessActivity,
          # GarminDump,
          # LastfmScrobble,
        ].each do |model|
          f.puts(JSON.generate(
            model.table_name => model.last_365_days.pluck(:date)
          ))
        end
      end
    end
  end
end
