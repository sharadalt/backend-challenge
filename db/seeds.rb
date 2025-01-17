# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# 5.times do
# 	Member.create!(
# 		first_name: Faker::Name.first_name,
# 		last_name:  Faker::Name.last_name,
# 		url: Faker::Internet.url(host: 'example.com'),
# 		email: Faker::Internet.email,
# 		password: Faker::Internet.password(min_length: 8)
# 	)
# end
5.times do
  puts "Creating user.."
  Member.create_member(
	  first_name: Faker::Name.first_name,
	  last_name:  Faker::Name.last_name,
	  url: Faker::Internet.url(host: 'example.com'),
	  email: Faker::Internet.email,
	  password: Base64.encode64("Mypassword")
  )
end
