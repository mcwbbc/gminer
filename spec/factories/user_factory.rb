Factory.define :user, :class => User do |u|
  u.email 'minimal@example.com'
  u.password 'test1234'
  u.password_confirmation 'test1234'
  u.admin true
end