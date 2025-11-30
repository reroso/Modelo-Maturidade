class AddAiFieldsToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :ai_generated, :boolean, default: false
    add_column :active_storage_blobs, :ai_confidence, :decimal, precision: 5, scale: 2
    add_column :active_storage_blobs, :reviewed_by_appraiser, :boolean, default: false
    add_column :active_storage_blobs, :appraiser_id, :integer
    add_index :active_storage_blobs, :appraiser_id
  end
end
