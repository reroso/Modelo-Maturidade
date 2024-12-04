class ChangeDescricaoToTextInResultados < ActiveRecord::Migration[6.0]
  def change
    change_column :resultados, :descricao, :text
  end
end
