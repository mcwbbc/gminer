ENV["RAILS_ENV"] = "test" if ENV["RAILS_ENV"].nil? || ENV["RAILS_ENV"] == ''
begin
  require 'rubygems'
  gem 'test-unit', '~> 2.0'
rescue Gem::LoadError
  puts "Could not find Test::Unit 2.0, ignoring"
end
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'rr'
require 'authlogic/test_case'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

# show less output on test benchmarks
# use (0,0) to suppress benchmark output entirely
Test::Unit::UI::Console::TestRunner.set_test_benchmark_limits(1,5)

# skip after_create callback during testing
class User < ActiveRecord::Base; def send_welcome_email; end; end

class ActiveSupport::TestCase
  include RR::Adapters::TestUnit

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  setup :activate_authlogic
end
