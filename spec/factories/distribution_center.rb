FactoryBot.define do
  factory :distribution_center do
    name { Faker::Lorem.word }
    location { Faker::Address.country }
  end
end