class AddMaturidadeToModeloAplicados < ActiveRecord::Migration[6.0]
  def change
    add_reference :modelo_aplicados, :maturidade, null: false, foreign_key: true
  end
end
