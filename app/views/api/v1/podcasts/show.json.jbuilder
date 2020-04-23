json.extract! @podcast, :id, :name, :description, :url, :subdomain, :feed_url, :cover_url, :episodes
json.user @podcast.user, :email, :first_name, :last_name
json.feed @rss_feed