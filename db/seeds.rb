# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all

#Create Users
User.create!(email: "paul@test.com", password: "password")

#Create Podcasts
Podcast.create!(user: User.first, subdomain: "jls", feed_url: "https://feeds.buzzsprout.com/740042.rss")
