# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    sequence(:address) { |n| "city-#{n}" }
    coordinate "[-6.185512, 106.824948]"

    association :area
  end

  factory :invalid_location, parent: :location do
    address nil
    coordinate nil
  end
end
