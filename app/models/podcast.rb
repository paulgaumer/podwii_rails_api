class Podcast < ApplicationRecord
  belongs_to :user
  has_many :episodes, dependent: :destroy

  validates :subdomain, presence: true, uniqueness: true

  serialize :instagram_access_token, JSON
end
