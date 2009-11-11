class User < ActiveRecord::Base
  generator_for :email, :method => :next_email
  generator_for :password => 'bobby'
  generator_for :password_confirmation => 'bobby'

  def self.next_email
    @base ||= 'BobDobbs'
    @base.succ!
    "#{@base}@example.com"
  end

end
