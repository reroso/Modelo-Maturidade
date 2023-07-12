class CreateProcessos < ActiveRecord::Migration[6.0]
  def change
    create_table :processos do |t|
      t.string :descricao

      t.timestamps
    end
  end
end
