FactoryBot.define do
  factory :inventory do
    available_amount { Faker::Number.number(4) }
    reserved_amount { Faker::Number.number(4) }
    association :product
    association :distribution_center
    #product_id nil
    #distribution_center_id nil
  end
end
