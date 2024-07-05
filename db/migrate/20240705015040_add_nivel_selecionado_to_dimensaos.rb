class AddNivelSelecionadoToDimensaos < ActiveRecord::Migration[6.0]
  def change
    add_column :dimensaos, :nivel_selecionado, :string, null: true
  end
end
