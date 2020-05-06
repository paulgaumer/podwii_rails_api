class Podcast < ApplicationRecord
  belongs_to :user
  has_many :episodes, dependent: :destroy
  has_many :crm_items, dependent: :destroy

  validates :subdomain, presence: true, uniqueness: true
end
