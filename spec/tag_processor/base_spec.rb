require 'spec_helper'

describe TagProcessor::Processor do
  class ::TagProcessor::TestProcessor < ::TagProcessor::Base
    @@revision = 1

    def self.process_fitness_activity(activity)
      # should not be called, it's stubbed
    end
  end

  let(:processor) { described_class.new(processors: [processor_klass]) }
  let(:processor_klass) { TagProcessor::TestProcessor }

  describe 'when never before run' do
    before do
      TagProcessingRecord.destroy_all
      FitnessActivity.destroy_all

      allow(processor_klass).to receive(:process_fitness_activity).and_return([])
    end

    describe '#process' do
      it 'calls .process_fitness_activity once' do
        activity = FitnessActivity.create(file_name: '123', data: '<!-- todo xml -->')
        expect(processor_klass).to receive(:process_fitness_activity).with(activity).once
        processor.process
        processor.process
        expect(TagProcessingRecord.count).to eq(1)
      end
    end
  end
end
