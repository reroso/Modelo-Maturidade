class CreateExpertiseAreas < ActiveRecord::Migration[6.0]
  def change
    # Tabela para armazenar as áreas de atuação únicas
    create_table :expertise_areas do |t|
      t.string :name
      t.timestamps
    end

    # Tabela de junção para relacionamento many-to-many
    create_table :appraiser_expertise_areas do |t|
      t.references :appraiser, foreign_key: true
      t.references :expertise_area, foreign_key: true
      t.timestamps
    end

    # Adicionar coluna name para appraisers
    add_column :appraisers, :name, :string
  end
end
