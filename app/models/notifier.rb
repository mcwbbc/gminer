class Notifier < ActionMailer::Base

  case Rails.env
    when "development"
      host = "development"
    when "production"
      host = "production"
    when "processing"
      host = "processing"
    when "staging"
      host = "staging"
  end

  default_url_options[:host] = host

  def password_reset_instructions(user)
    setup(user)
    subject I18n.t("subject.password_reset_instructions")
    body :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def welcome_email(user)
    setup(user)
    subject I18n.t("subject.welcome")
    body :user => user
  end

  def activation_instructions(user)
  setup(user)
  subject I18n.t("subject.activation_instructions")
  body :account_activation_url => activate_url(user.perishable_token)
end


private

  def setup(user)
    from "email@mcw.edu"
    sent_on Time.now
    recipients user.email
  end

end
