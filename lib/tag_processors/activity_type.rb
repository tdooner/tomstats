module TagProcessors
  class ActivityType
    def self.process_fitness_activity(activity)
      type = FitnessActivity.connection.execute(<<-SQL).first['type']
        select
          unnest(xpath('//ns:Activity/@Sport', data,
            ARRAY[ARRAY['ns', 'http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2']]
          ))::varchar AS type
        from fitness_activities
        where id = #{activity.id};
      SQL

      "type:#{type.downcase}"
    end
  end
end
