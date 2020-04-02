# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Podcast.destroy_all

#Create Users
User.create!(email: "paul@test.com", password:"password")
User.create!(email: "bob@test.com", password:"password")

#Create Podcasts
Podcast.create!(name: "Hello World", description: "Best podcast in the world!", url:"https://google.com", user: User.first)