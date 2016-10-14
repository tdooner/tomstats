module TagProcessor
  class Processor
    def initialize
      TagProcessor::Base.class_variable_get(:@@processors).each do |processor_klass|
        processor_revision = processor_klass.class_variable_get(:@@revision)

        processor_klass.each_model do |model|
          TagProcessingRecord
            .where(processor: processor_klass.name)
            .where.not(revision: processor_revision)
            .destroy_all

          model.joins(
            "LEFT OUTER JOIN tag_processing_records
               ON tag_processing_records.source_id = #{model.table_name}.id
              AND tag_processing_records.source_type = '#{model.name}'
              AND processor = '#{processor_klass.name}'")
            .where(tag_processing_records: { id: nil })
            .find_each do |record|
              $stdout.write "#{processor_klass} (id=#{record.id})... "

              tags = Array(processor_klass.process_fitness_activity(record))
              tags = [nil] if tags.empty?

              TagProcessingRecord.transaction do
                tags.each do |tag|
                  TagProcessingRecord.create(
                    source: record,
                    processor: processor_klass.name,
                    revision: processor_revision,
                    tag: tag
                  )
                end
              end

              $stdout.puts "done\t\t#{tags.length - tags.count(&:nil?)} tags"
            end
        end
      end
    end
  end
end
