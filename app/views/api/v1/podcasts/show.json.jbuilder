json.extract! @podcast, :id, :name, :description, :url, :audio_player, :subdomain
json.user @podcast.user, :email