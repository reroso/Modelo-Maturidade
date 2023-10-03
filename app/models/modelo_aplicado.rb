class ModeloAplicado < ApplicationRecord
    has_many :maturidades
    has_many :dominios
end
