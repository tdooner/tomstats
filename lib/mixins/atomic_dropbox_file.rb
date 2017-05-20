require 'active_support/concern'

module Mixins
  module AtomicDropboxFile
    extend ActiveSupport::Concern

    class_methods do
      def atomically_process_files_in(client, dropbox_dir)
        processed_files = distinct(:file_name).pluck(:file_name)

        client.list_directory(dropbox_dir).each do |file|
          next if processed_files.include?(file.name)

          self.transaction do
            yield file
          end
        end
      end
    end
  end
end
