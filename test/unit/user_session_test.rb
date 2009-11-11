require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  # note - not an AR class

  should "derive from Authlogic::Session::Base" do
    Authlogic::Session::Base.controller = stub!('controller')
    us = UserSession.new
    assert us.is_a?(Authlogic::Session::Base)
  end

end
