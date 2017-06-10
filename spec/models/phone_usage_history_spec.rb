require 'spec_helper'

RSpec.describe PhoneUsageHistory do
  describe '.create_from_row' do
    let(:headers) { '"App name","Date","Time","Duration"' }
    let(:parsed) { CSV.parse(headers + "\n" + row, headers: :first_row) }
    let(:row) { '"ZenUI Launcher","2/4/17","2:00:08 PM","00:08"' }

    def create_from_row
      PhoneUsageHistory
        .where(file_name: 'some_file_name.csv')
        .create_from_row(parsed.first)
    end

    subject { create_from_row }

    it 'does not recreate a duplicate row' do
      expect { create_from_row }
        .to change { PhoneUsageHistory.count }
        .by(1)

      expect { create_from_row }
        .not_to change { PhoneUsageHistory.count }
    end

    describe 'with an invalid row' do
      let(:row) { "Created by App Usage on Saturday, February 4, 2017, 2:00 PM" }

      it 'skips the row' do
        expect { expect(subject).to be_nil }
          .not_to change { PhoneUsageHistory.count }
      end
    end

    describe 'with a row with min/sec duration' do
      let(:row) { '"ZenUI Launcher","2/4/17","2:00:08 PM","00:08"' }

      it 'creates a row' do
        expect { subject }
          .to change { PhoneUsageHistory.count }
          .by(1)

        expect(PhoneUsageHistory.last.duration)
          .to eq('00:00:08')
      end
    end

    describe 'with a row with hour/min/sec duration' do
      let(:row) { '"Screen locked","2/3/17","11:45:46 PM","1:00:14"' }

      it 'creates a row' do
        expect { subject }
          .to change { PhoneUsageHistory.count }
          .by(1)

        expect(PhoneUsageHistory.last.duration)
          .to eq('01:00:14')
      end
    end

    describe 'with a row from v4 format' do
      let(:row) { '"Chrome","6/10/17","10:03:27","04:30"' }

      it 'creates a row' do
        expect { subject }
          .to change { PhoneUsageHistory.count }
          .by(1)

        expect(PhoneUsageHistory.last.duration)
          .to eq('00:04:30')
      end
    end
  end
end
