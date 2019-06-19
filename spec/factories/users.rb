FactoryBot.define do
  factory :user do
    email {  Faker::Internet.email }
    password { 'Test@123' }
  end
end
