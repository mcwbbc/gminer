ActionMailer::Base.smtp_settings = {
  :address => "mailserver",
  :port    => 25,
  :domain => "webserver",
  :authentication => nil,
}

# base64 encodings - useful for manual SMTP testing:
# username => dXNlcm5hbWU=

# password => cGFzc3dvcmQ=
