class AddDominioToModeloAplicados < ActiveRecord::Migration[6.0]
  def change
    add_reference :modelo_aplicados, :dominio, null: false, foreign_key: true
  end
end
