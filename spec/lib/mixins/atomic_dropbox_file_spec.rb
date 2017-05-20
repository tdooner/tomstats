require 'spec_helper'

RSpec.describe Mixins::AtomicDropboxFile do
  before do
    ActiveRecord::Base.connection.create_table(:test_objects) do |t|
      t.string :file_name
    end
  end

  after do
    ActiveRecord::Base.connection.drop_table(:test_objects)
  end

  class TestObject < ActiveRecord::Base
    include Mixins::AtomicDropboxFile
  end

  let(:client) { double('dropbox', list_directory: [file]) }
  let(:file) { double('file', name: 'foo.txt', download: 'body') }

  it 'yields a file that has not yet been processed' do
    expect { |ex| TestObject.atomically_process_files_in(client, '/foo', &ex) }
      .to yield_with_args(file)
  end

  it 'yields inside a transaction' do
    TestObject.atomically_process_files_in(client, '/foo') do |file|
      # one transaction for database cleaning, one transaction in the method
      # under test
      expect(TestObject.connection.open_transactions).to eq(2)
    end
  end

  describe 'when a file already has been processed' do
    before do
      TestObject.create(file_name: file.name)
    end

    it 'does not yield that file' do
      expect { |ex| TestObject.atomically_process_files_in(client, '/foo', &ex) }
        .not_to yield_control
    end
  end
end
