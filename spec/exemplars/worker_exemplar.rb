class Worker < ActiveRecord::Base
  generator_for :working => false
  generator_for :ready => true
  generator_for :worker_key => "abcd-1234"
end
