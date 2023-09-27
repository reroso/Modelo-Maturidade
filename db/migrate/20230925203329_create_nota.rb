class CreateNota < ActiveRecord::Migration[6.0]
  def change
    create_table :nota do |t|
      t.string :descricao

      t.timestamps
    end
  end
end
