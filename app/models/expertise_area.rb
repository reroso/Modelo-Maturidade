class ExpertiseArea < ApplicationRecord
  has_many :appraiser_expertise_areas
  has_many :appraisers, through: :appraiser_expertise_areas

  validates :name, presence: true, uniqueness: true
end
