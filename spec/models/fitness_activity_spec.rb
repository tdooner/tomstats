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
      activity = FitnessActivity.create(dropbox_rev: '123', data: SAMPLE)
      activity.reload
      expect(activity.date).to eq(Date.new(2016, 5, 15))
    end
  end
end
