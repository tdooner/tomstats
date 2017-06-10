module Builder
  autoload :DateHistogram, 'builder/date_histogram.rb'
  autoload :PhoneUsage, 'builder/phone_usage.rb'

  class Base
    def initialize
      @data = nil
    end

    # must set a @data instance variable
    def calculate
      raise NotImplementedError
    end

    def to_json
      JSON.pretty_generate(@data)
    end

    def save(output = default_filename)
      File.open(output, 'w') do |f|
        f.puts(self.to_json)
      end
    end

    private

    def default_filename
      name = self.class.name.demodulize.underscore
      File.expand_path("../../build/data/#{name}.json", __FILE__)
    end
  end
end
