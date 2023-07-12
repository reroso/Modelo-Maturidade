class AddDimensaoToProcessos < ActiveRecord::Migration[6.0]
  def change
    add_reference :processos, :dimensao, null: false, foreign_key: true
  end
end
