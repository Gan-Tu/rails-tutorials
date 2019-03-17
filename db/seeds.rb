# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# create my own user
User.create!(name:  "Gan Tu",
             email: "example@tugan.me",
             password:              "970329",
             password_confirmation: "970329",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)


# create example rails user
User.create!(name:  "Example Admin User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)


# create example rails user
User.create!(name:  "Example Unactivated User",
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
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end