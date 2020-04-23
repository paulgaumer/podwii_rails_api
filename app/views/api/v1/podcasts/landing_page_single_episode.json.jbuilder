# json.extract! @podcast, :id, :name, :description, :url, :feed_url, :cover_url
# json.user @podcast.user, :email, :first_name, :last_name
json.episodeRss @episode_rss
json.episodeDb @episode_db