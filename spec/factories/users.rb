FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
    email { Faker::Internet.free_email }
    password { Faker::Internet.password(min_length: 6) }

    after(:create) do |user|
      create(:status, user: user)
      create(:avatar, user: user)
    end
  end
end
