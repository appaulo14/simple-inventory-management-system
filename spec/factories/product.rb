FactoryBot.define do
  factory :product do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
  end
end