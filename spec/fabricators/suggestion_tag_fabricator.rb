Fabricator(:suggestion_tag) do
  order            Faker::Number.number(1)
  suggestion_type  0
  description      Faker::Lorem.word
end
