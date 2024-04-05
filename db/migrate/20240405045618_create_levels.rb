class CreateLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :levels do |t|
      t.string :index
      t.text :descricao
      t.integer :modelo_id

      t.timestamps
    end
  end
end
