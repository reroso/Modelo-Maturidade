class Processo < ApplicationRecord
    belongs_to :dimensao
    has_many :resultados, dependent: :destroy
end
