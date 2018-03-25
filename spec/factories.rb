FactoryBot.define do
  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :name do |n|
    "name#{n}"
  end

  factory :transaction do

  end

  factory :watch do
    name { generate :name }
  end

  factory :image do
    name { generate :name }
  end

  factory :user do
    name { generate :name }
    email { generate :email }
    password "123456"
    password_confirmation "123456"
  end
end
