class AddProcessoToResultados < ActiveRecord::Migration[6.0]
  def change
    add_reference :resultados, :processo, null: false, foreign_key: true
  end
end
