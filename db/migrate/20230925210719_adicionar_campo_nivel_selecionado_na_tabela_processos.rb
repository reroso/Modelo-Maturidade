class AdicionarCampoNivelSelecionadoNaTabelaProcessos < ActiveRecord::Migration[6.0]
  def change
    add_column :processos, :nivel_selecionado, :string, null: true
    add_column :resultados, :nivel_selecionado, :string, null: true
  end
end
