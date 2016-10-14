module TagProcessor
  class Base
    @@processors = []
    @@models = [
      ['FitnessActivity', :process_fitness_activity],
    ]

    def self.inherited(subclass)
      @@processors << subclass
    end

    def self.each_model(&block)
      @@models.each do |name, method|
        klass = const_get(name)
        block.call(klass) if respond_to?(method)
      end
    end
  end
end
