FactoryBot.define do
  factory :auth_token do
    domain
    user { create :admin }

    token { '5zuld3g9dv76yosy' }
    permissions { {
      'policy' => 'deny',
      'new' => false,
      'remove' => false,
      'protected' => [],
      'protected_types' => [],
      'allowed' => [
        ['example.com', '*'],
        ['www.example.com', '*']
      ]
    } }
    expires_at { 3.hours.since }
  end

  factory :api_client do
    name { "Some api client" }
    authentication_token { "124783tsdjfhgsdjk" }
  end
end
