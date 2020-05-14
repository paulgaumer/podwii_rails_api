class Subdomain < ApplicationRecord
  belongs_to :podcast

  validates :name, presence: true, uniqueness: { message: " is already taken" }
end
