class Podcast < ApplicationRecord
  belongs_to :user
  has_many :episodes, dependent: :destroy

  validates :subdomain, presence: true, uniqueness: true
end
