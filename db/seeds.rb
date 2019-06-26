# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Set Random Seed
srand(777)
Faker::Config.random = Random.new(777)

puts "[INFO] Seeding database with example users..."

# create my own user
User.create!(name:  "Gan Tu",
             email: "example@tugan.me",
             password:              "970329",
             password_confirmation: "970329",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)


# create example rails user
User.create!(name:  "Admin User - Example",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)


# create example rails user
User.create!(name:  "Unactivated User - Example",
             email: "unactivated@example.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: false,
             activated: false,
             activated_at: Time.zone.now)

# create more dummy users
99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "#{name}-password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

# Fake microposts
puts "[INFO] Seeding database with example posts..."
User.all.each { |user|
  num_posts = rand(1..30)
  num_posts.times {
    content = Faker::Lorem.sentence(5)
    post = user.microposts.create(content: content)
    post.created_at = rand(1..60*24).minutes.ago
    post.save
  }
}

# Following relationships
puts "[INFO] Seeding database with example relationships..."
all_users = User.all[0..50]
all_users.each { |user|
  num_follow = rand(1..all_users.length)
  all_users.shuffle[0..num_follow].each{ |other|
    if user != other
      user.follow(other)
    end
  }
}

