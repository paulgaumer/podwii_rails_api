class Podcast < ApplicationRecord
  belongs_to :user

  validates :subdomain, presence: true, uniqueness: true
end
