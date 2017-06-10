require 'spec_helper'

SAMPLE = <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<TrainingCenterDatabase>
  <Activities>
    <Activity Sport="Running">
      <Id>2016-05-15T15:03:10.000Z</Id>
    </Activity>
  </Activities>
</TrainingCenterDatabase>
XML

describe FitnessActivity do
  describe 'on save' do
    it 'extracts the date from the <Activity>' do
      activity = FitnessActivity.create(file_name: '2016-05-05 Running.tcx', data: SAMPLE)
      activity.reload
      expect(activity.date).to eq(Date.new(2016, 5, 15))
    end
  end

  describe '.create_from_file' do
    let(:dropbox_file) do
      double('file', name: '2017-01-01 Running.tcx', download: SAMPLE)
    end

    subject { described_class.create_from_file(dropbox_file) }

    it 'creates a FitnessActivity record' do
      expect { subject }.to change { FitnessActivity.count }.by(1)
    end
  end
end
