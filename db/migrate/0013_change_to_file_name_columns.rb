class ChangeToFileNameColumns < ActiveRecord::Migration[5.0]
  def change
    # 1. rename this column (easy)
    rename_column :phone_usage_histories, :csv_name, :file_name

    # 2. change from dropbox rev to using filename
    change_table :fitness_activities do |f|
      f.string :file_name
    end

    # 3. match all the file names and save them
    if FitnessActivity.count > 0
      say 'backfilling FitnessActivity records'
      dropbox = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
      FitnessActivity.transaction do
        dropbox.list_directory('/Apps/tapiriik').each do |file|
          say "#{file.rev} -> #{file.name}", true
          FitnessActivity
            .where(dropbox_rev: file.rev)
            .update_all(file_name: file.name)
        end
      end
    end

    # 4. add unique constraint
    add_index :fitness_activities, :file_name, unique: true
    change_column :fitness_activities, :file_name, :string, null: false

    # 5. remove old data
    remove_column :fitness_activities, :dropbox_rev
  end
end
