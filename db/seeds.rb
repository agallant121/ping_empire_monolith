# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Website.destroy_all

websites = Website.create!([
  { url: "https://google.com" },
  { url: "https://yahoo.com" },
  { url: "https://askjeeves" }
])

websites.each do |website|
  3.times do
    website.responses.create!(
      status_code: [ 200, 404, 500 ].sample,
      response_time: rand(100..1000),
      error: [ nil, "Timeout", "Connection refused" ].sample
    )
  end
end

puts "Seeded #{Website.count} websites and #{Response.count} responses."
