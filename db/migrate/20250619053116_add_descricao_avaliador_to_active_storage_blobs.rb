class AddDescricaoAvaliadorToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :descricao_avaliador, :text
  end
end
