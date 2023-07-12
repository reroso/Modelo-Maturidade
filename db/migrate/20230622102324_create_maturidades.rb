class CreateMaturidades < ActiveRecord::Migration[6.0]
  def change
    create_table :maturidades do |t|
      t.string :nome
      t.string :descricao
      t.string :tipoNivel
      t.string :menorNivel
      t.string :maiorNivel
      t.string :resultadoEscolha
      t.string :nivelEscolha

      t.timestamps
    end
  end
end
