class Resultado < ApplicationRecord
    belongs_to :processo
    has_many_attached :docs

    validates :descricao, presence: true
    validates :processo_id, presence: true
end
