Dir[File.join(Rails.root, 'lib', '*.rb')].each do |f|
  require f
end

require 'csv'
require 'net/ftp'
require 'tag.rb' #Because we're adding to the class it needs to be required?