class CreateDimensaos < ActiveRecord::Migration[6.0]
  def change
    create_table :dimensaos do |t|
      t.string :descricao

      t.timestamps
    end
  end
end
