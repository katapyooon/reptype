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

    # Temporarily replaces an instance method on +klass+ for the duration of the block.
    # Used to bypass unrelated before_actions (e.g. authorization) in controller tests
    # that aren't exercising that check itself, since session mutation doesn't take
    # effect until a real request has written a session cookie.
    def stub_instance_method(klass, method_name, value)
      original = klass.instance_method(method_name)
      klass.send(:define_method, method_name) do |*args|
        value.respond_to?(:call) ? instance_exec(*args, &value) : value
      end
      yield
    ensure
      klass.send(:define_method, method_name, original)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # 認証なしで公開したくないルートが存在しないことを確認する
    def assert_no_route(verb, path)
      recognized = Rails.application.routes.recognize_path(path, method: verb)
      flunk "expected no route for #{verb.upcase} #{path}, but it routes to #{recognized.inspect}"
    rescue ActionController::RoutingError
      pass
    end
  end
end
