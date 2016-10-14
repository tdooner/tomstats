if __FILE__ == $0
  require_relative '../../environment.rb'
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  puts TagProcessor::ActivityType.process_fitness_activity(FitnessActivity.last)
end

require 'rexml/document'
require 'rexml/xpath'

module TagProcessor
  class ActivityType < Base
    @@revision = 1

    def self.process_fitness_activity(activity)
      doc = REXML::Document.new(activity.data, ignore_whitespace_nodes: :all)
      type = REXML::XPath.match(doc, '//Activity/@Sport')[0].value

      "type:#{type.downcase}"
    end
  end
end
