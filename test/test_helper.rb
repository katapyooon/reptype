ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Temporarily replaces a singleton method on +klass+ for the duration of the block.
    # +value+ may be a plain value or a callable (e.g. a lambda that raises).
    # A dependency-free stand-in for minitest/mock's Object#stub, which is not
    # available here (minitest/mock is a bundled gem not declared in the Gemfile).
    def stub_class_method(klass, method_name, value)
      original = klass.method(method_name)
      klass.define_singleton_method(method_name) do |*args|
        value.respond_to?(:call) ? value.call(*args) : value
      end
      yield
    ensure
      klass.define_singleton_method(method_name, original)
    end
  end
end
