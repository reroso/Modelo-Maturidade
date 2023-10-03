class CreateModeloAplicados < ActiveRecord::Migration[6.0]
  def change
    create_table :modelo_aplicados do |t|
      t.string :metodo
      t.string :instituicao

      t.timestamps
    end
  end
end
