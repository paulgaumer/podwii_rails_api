json.extract! @podcast, :id, :name, :description, :url, :audio_player
json.user @podcast.user, :email