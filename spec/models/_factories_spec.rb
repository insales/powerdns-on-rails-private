require "spec_helper"

RSpec.describe "Factories" do
  it "are linted" do
    disabled_factories = %i{
    }
    pending_factories = %i{
    }

    options = {
      # TODO: пропихнуть в апстрим:
      # progress: true
    }
    factories_to_lint = FactoryGirl.factories.reject{|f| disabled_factories.include?(f.name) || pending_factories.include?(f.name) }
    FactoryBot::Linter.new(factories_to_lint, **options).lint!

    if pending_factories.any?
      pending "pending factories"
      FactoryBot::Linter.new(FactoryGirl.factories.select{|f| pending_factories.include?(f.name) }, **options).lint!
    end
  end
end
