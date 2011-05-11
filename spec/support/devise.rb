RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end

RSpec.configure do |config|
  config.extend ControllerMacros, :type => :controller
end
