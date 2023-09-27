class Resultado < ApplicationRecord
    belongs_to :processo
    has_many_attached :docs
end
