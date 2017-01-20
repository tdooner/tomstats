require 'active_support/core_ext/string/inflections'

module TagProcessor
  class Base
    @@models = [
      ['FitnessActivity', :process_fitness_activity],
    ]

    def self.each_model(&block)
      @@models.each do |name, method|
        klass = const_get(name)
        block.call(klass) if respond_to?(method)
      end
    end
  end

  # TODO: name this something else since Processor here describes two different
  # things.
  class Processor
    def initialize(processors: [])
      @processors = processors
    end

    def discover_processors(directory)
      Dir[File.join(directory, '*.rb')].each do |file|
        class_name = File.basename(file, '.rb').classify

        begin
          require file
          klass = TagProcessor.const_get(class_name)
        rescue NameError
          raise "Expected #{file} to define TagProcessor::#{class_name}."
        end

        @processors << klass
      end
    end

    def process(logger: Logger.new('/dev/null'))
      logger.debug "Processing #{@processors.length} processors: #{@processors.inspect}"

      @processors.each do |processor_klass|
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
            .find_each(batch_size: 1) do |record|
              logger.debug "#{processor_klass} (id=#{record.id})... "

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

              logger.debug "done\t\t#{tags.length - tags.count(&:nil?)} tags"
            end
        end
      end
    end
  end
end
