FactoryBot.define do
  sequence :macro_name do |i|
    "Some macro #{i}"
  end

  factory(:macro) do
    name { generate :macro_name }
    active { true }
  end

  factory :macro_step do
    macro

    factory(:macro_step_create, :class => MacroStep) do
      action { 'create' }
      record_type { 'A' }
      name { 'auto' }
      content { '127.0.0.1' }
    end

    factory(:macro_step_change, :class => MacroStep) do
      action { 'update' }
      record_type { 'A' }
      name { 'www' }
      content { '127.1.1.1' }
    end

    factory(:macro_step_remove, :class => MacroStep) do
      action { 'remove' }
      record_type { 'A' }
      name { 'ftp' }
    end
  end
end

