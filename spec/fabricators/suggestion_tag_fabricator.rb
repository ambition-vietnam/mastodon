Fabricator(:suggestion_tag) do
  tag
  order            Faker::Number.number(1)
  description      Faker::Lorem.word
  suggestion_type  :normal
end
