class Appraiser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :appraiser_expertise_areas
  has_many :expertise_areas, through: :appraiser_expertise_areas
end
