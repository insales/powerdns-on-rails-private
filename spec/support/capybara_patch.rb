
module Capybara
  module RSpecMatchers
    class Matcher
      include ::RSpec::Matchers::Composable if defined?(::RSpec::Version) && ::RSpec::Version::STRING.to_f >= 3.0

      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        elsif actual.respond_to?(:body)
          # чтобы прокатывало response.should have_selector(...)
          # ActionController::TestResponse
          Capybara.string(actual.body)
        else
          Capybara.string(actual.to_s)
        end
      end
    end
  end
end
