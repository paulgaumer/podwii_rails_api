class Episode < ApplicationRecord
  belongs_to :podcast
  # serialize :enclosure, JSON
  # serialize :cover_image, JSON
end
