class AddDominioToModeloAplicados < ActiveRecord::Migration[6.0]
  def change
    add_column :modelo_aplicados, :dominio, :string
  end
end
