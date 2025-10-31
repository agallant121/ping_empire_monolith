User.destroy_all
Website.destroy_all # destroys dependednent responses

puts "💃🏼 Seeding user..."

user = User.create!(
  email: "user@example.com",
  password: "asdfasdf123!",
  password_confirmation: "asdfasdf123!"
  )

puts "✅💃🏼 User seeded..."

puts "💾 Seeding websites..."

urls = %w[
  https://google.com
  https://apple.com
  https://microsoft.com
  https://amazon.com
  https://youtube.com
  https://wikipedia.org
  https://twitter.com
  https://linkedin.com
  https://nytimes.com
  https://bbc.com
  https://cnn.com
  https://github.com
  https://rubyonrails.org
  https://reddit.com
  https://shopify.com
  https://salesforce.com
  https://adobe.com
  https://airbnb.com
  https://nasa.gov
  https://harvard.edu
  https://mit.edu
  https://stanford.edu
  https://whitehouse.gov
  https://who.int
  https://imdb.com
  https://espn.com
  https://bloomberg.com
  https://reuters.com
  https://washingtonpost.com
  https://theguardian.com
  https://forbes.com
  https://nationalgeographic.com
  https://coursera.org
  https://udemy.com
  https://medium.com
  https://yelp.com
  https://dropbox.com
  https://zoom.us
  https://notion.so
  https://stripe.com
  https://slack.com
  https://asana.com
  https://figma.com
  https://heroku.com
  https://vercel.com
  https://netflix.com
  https://spotify.com
  https://tesla.com
  https://ford.com
  https://bmw.com
  https://toyota.com
  https://nintendo.com
]

websites = urls.map { |url| Website.create!(url: url, user: user) }

puts "✅ 💾 Websites seeded..."

puts "👄 Seeding responses..."

websites.each do |website|
  50.times do
    website.responses.create!(
      status_code: [ 200, 201, 204, 301, 302, 304 ].sample,
      response_time: rand(50..800),
      error: nil
    )
  end
end

responses = Response.all

responses.sample(3).each do |response|
  response.update!(
    status_code: [ 400, 401, 403, 404, 408, 500, 502, 503 ].sample,
  )
end

puts "✅ 👄 Responses seeded..."
puts "✅ Seeded #{Website.count} websites and #{Response.count} responses."
