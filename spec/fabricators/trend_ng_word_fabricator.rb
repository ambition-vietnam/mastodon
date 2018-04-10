Fabricator(:trend_ng_word) do
  word { sequence(:word) }
  memo Faker::Lorem.sentence
end
