class CreateResultados < ActiveRecord::Migration[6.0]
  def change
    create_table :resultados do |t|
      t.string :descricao

      t.timestamps
    end
  end
end
