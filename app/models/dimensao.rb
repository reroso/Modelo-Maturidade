class Dimensao < ApplicationRecord
    has_many :processos, dependent: :destroy
    belongs_to :maturidade
end
