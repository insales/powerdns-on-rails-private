require "spec_helper"

RSpec.describe "Factories" do
  it "are linted" do
    disabled_factories = %i{
      record_template record macro_step
    }
    pending_factories = %i{
    }

    options = {
      # TODO: пропихнуть в апстрим:
      # progress: true
    }
    factories_to_lint = FactoryBot.factories.reject{|f| disabled_factories.include?(f.name) || pending_factories.include?(f.name) }
    FactoryBot.lint(factories_to_lint, **options)

    if pending_factories.any?
      pending "pending factories"
      FactoryBot.lint(FactoryBot.factories.select{|f| pending_factories.include?(f.name) }, **options)
    end
  end
end
