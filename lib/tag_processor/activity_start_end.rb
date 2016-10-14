require 'rexml/document'
require 'rexml/xpath'

module TagProcessor
  class ActivityStartEnd < Base
    @@revision = 2

    HOME = [-122.427328, 37.759519, -122.422779, 37.763353]
    BRIGADE = [-122.3967826366, 37.7797886414, -122.3945295811, 37.7814167379]

    def self.process_fitness_activity(activity)
      doc = REXML::Document.new(activity.data, ignore_whitespace_nodes: :all)
      points = REXML::XPath.match(doc, '/TrainingCenterDatabase/Activities/Activity/Lap/Track/Trackpoint')
      tags = []

      first_few_points = points
        .map { |p| _process_trackpoint(p) }
        .find_all { |p| p['LongitudeDegrees'] && p['LongitudeDegrees'] != 0 }
        .first(5)

      last_few_points = points
        .map { |p| _process_trackpoint(p) }
        .find_all { |p| p['LongitudeDegrees'] && p['LongitudeDegrees'] != 0 }
        .last(5)

      [
        [HOME, 'home'],
        [BRIGADE, 'brigade'],
      ].each do |box, name|
        if first_few_points.any? { |point| _is_point_in_box(point, box) }
          tags << "activity_start:#{name}"
        end

        if last_few_points.any? { |point| _is_point_in_box(point, box) }
          tags << "activity_end:#{name}"
        end
      end

      tags
    end

    def self._is_point_in_box(point, box)
      minlng, minlat, maxlng, maxlat = box

      minlng < point['LongitudeDegrees'] && point['LongitudeDegrees'] < maxlng &&
      minlat < point['LatitudeDegrees']  && point['LatitudeDegrees'] < maxlat
    end

    def self._process_trackpoint(trackpoint)
      {}.tap do |hash|
        trackpoint.each_recursive do |point|
          hash[point.name] = point.text
        end

        hash['Time'] = Time.parse(hash['Time'])
        hash['LatitudeDegrees'] = hash['LatitudeDegrees'].to_f
        hash['LongitudeDegrees'] = hash['LongitudeDegrees'].to_f
      end
    end
  end
end

if __FILE__ == $0
  require_relative '../../environment.rb'
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  puts TagProcessors::ActivityStartEnd.process_fitness_activity(FitnessActivity.last)
end
