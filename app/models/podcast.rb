class Podcast < ApplicationRecord
  belongs_to :user
  has_many :episodes

  validates :subdomain, presence: true, uniqueness: true
end
