FactoryBot.define do
  sequence :user_email do |i|
    "user#{i}@example.com"
  end

  factory :user do
    email { generate :user_email }
    password { 'secret' }
    password_confirmation { 'secret' }
    confirmation_token { nil }
    confirmed_at { Time.now }
    state { "active" }

    factory :admin do
      login { 'admin' }
      # email 'admin@example.com'
      admin { true }
    end

    factory :quentin do
      login { 'quentin' }
      email { 'quentin@example.com' }
    end

    factory :aaron do
      login { 'aaron' }
      email { 'aaron@example.com' }
    end

    factory :token_user  do
      login { 'token' }
      email { 'token@example.com' }
      admin  { true }
      auth_tokens { true }
    end

    factory :api_client do
      login { 'api' }
      email { 'api@example.com' }
      admin { true }
    end
  end
end
