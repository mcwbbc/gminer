require 'test_helper'

class NotifierTest < ActionMailer::TestCase

  should "send welcome email" do
    user = User.generate!
    Notifier.deliver_welcome_email(user)
    assert_sent_email do |email|
      email.subject = "Welcome to gminer!"
      email.from.include?('JGeiger <jfgeiger@mcw.edu>')
      email.to.include?(user.email)
    end
  end

  should "send password reset instructions" do
    user = User.generate!
    Notifier.deliver_password_reset_instructions(user)
    assert_sent_email do |email|
      email.subject = "Password Reset Instructions"
      email.from.include?('JGeiger <jfgeiger@mcw.edu>')
      email.to.include?(user.email)
      email.body =~ Regexp.new(user.perishable_token)
    end
  end

  should "send activation instructions" do
  user = User.generate!
   Notifier.deliver_activation_instructions(user)
     assert_sent_email do |email|
       email.subject = "Activation Instructions"
       email.from.include?('JGeiger <jfgeiger@mcw.edu>')
       email.to.include?(user.email)
       email.body =~ Regexp.new(user.perishable_token)
     end
   end


end
