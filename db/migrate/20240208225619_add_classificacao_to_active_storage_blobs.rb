class AddClassificacaoToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :classificacao, :integer
  end
end
