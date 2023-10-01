class CreateDominios < ActiveRecord::Migration[6.0]
  def change
    create_table :dominios do |t|
      t.string :nome

      t.timestamps
    end
  end
end
