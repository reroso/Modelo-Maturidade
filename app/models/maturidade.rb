class Maturidade < ApplicationRecord
    has_many :dimensaos, dependent: :destroy
end
