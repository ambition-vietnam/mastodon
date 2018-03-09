Fabricator(:outgoing_webhook) do
  name          { sequence(:name) { |i| "#{Faker::Name.name}" } }
  url           Faker::Internet.url
  trigger_word  Faker::Lorem.word
  account_id    Faker::Number.number(1)
end
