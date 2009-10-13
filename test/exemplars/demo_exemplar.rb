class Company < ActiveRecord::Base
  generator_for :country => "USA"
  generator_for :organization => "Joe's Garage"
  generator_for :login, :method => :next_login
  generator_for :plan => nil
  generator_for (:currency_id) {Currency.generate.id}

  # don't worry about subscription stuff in test
  alias_method :old_valid_plan?, :valid_plan?
  def valid_plan?
    true
  end

  def self.next_login
    @last_login ||= 'joesgarage'
    @last_login.succ!
  end
end
