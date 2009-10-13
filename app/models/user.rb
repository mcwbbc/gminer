class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validates_length_of_password_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.disable_perishable_token_maintenance(true)
  end

  serialize :roles, Array

  before_validation_on_create :make_default_roles

  attr_accessible :email, :password, :password_confirmation

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def deliver_activation_instructions!
    reset_perishable_token!
    Notifier.deliver_activation_instructions(self)
  end

  def deliver_welcome_email!
    reset_perishable_token!
    Notifier.deliver_welcome_email(self)
  end

  def has_no_credentials?
    self.crypted_password.blank?
  end

  def signup!(params)
    self.email = params[:user][:email]
    save_without_session_maintenance
  end

  def activate!(params = nil)
    self.active = true
    if params
      self.password = params[:user][:password]
      self.password_confirmation = params[:user][:password_confirmation]
    end
    save
  end

  def admin?
    has_role?("admin")
  end

  def has_role?(role)
    roles.include?(role)
  end

  def add_role(role)
    self.roles << role
  end

  def remove_role(role)
    self.roles.delete(role)
  end

  def clear_roles
    self.roles = []
  end

  def kaboom!
    r = RegExp.new("foo")
  end

private
  def make_default_roles
    clear_roles if roles.nil?
  end

end
