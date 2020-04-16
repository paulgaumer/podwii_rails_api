json.extract! @podcast, :id, :name, :description, :url, :audio_player, :subdomain, :feed_url, :cover_url
json.user @podcast.user, :email, :first_name, :last_name
json.feed @rss_feed