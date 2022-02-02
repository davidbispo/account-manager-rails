FactoryBot.define do
  factory :account do
    balance { Faker::Number.number(digits:2) }

  end
end