class CreateTagProcessingRecord < ActiveRecord::Migration[5.0]
  create_table :tag_processing_records do |t|
    t.references :source, polymorphic: true
    t.string :processor
    t.integer :revision
    t.string :tag
  end
end
