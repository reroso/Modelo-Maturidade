class Dimensao < ApplicationRecord
    has_many :processos, dependent: :destroy
    belongs_to :maturidade
    has_many_attached :docs
end
