# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :smtp

config.gem 'ffmike-query_trace', :lib => 'query_trace', :source => 'http://gems.github.com'
config.gem 'bullet', :source => 'http://gemcutter.org'
config.middleware.use "Rack::Bug"

config.after_initialize do
  Bullet.enable = false           # flip to true to enable bullet
  Bullet.alert = true             # javascript alert in browser
  Bullet.bullet_logger = true     # log to separate bullet.log
  Bullet.console = true           # log to browser console (Webkit or Firebug)
  Bullet.growl = false            # log to Growl
  Bullet.rails_logger = false     # log to current Rails log
  Bullet.disable_browser_cache = true
end

config.cache_store = :mem_cache_store, { :namespace => 'gminer' }

memcache_options = {
  :c_threshold => 10000,
  :compression => true,
  :debug => false,
  :namespace => 'gminer',
  :readonly => false,
  :urlencode => false
}

# require the new gem, this will load up 1.7.5 instead of using the built in 1.5.0
require 'memcache'

# make a CACHE global to use in your controllers instead of Rails.cache, this will use the new memcache-client 1.7.2
CACHE = MemCache.new(memcache_options)

# connect to your server that you started earlier
CACHE.servers = '127.0.0.1:11211'

# this is where you deal with passenger's forking
begin
 PhusionPassenger.on_event(:starting_worker_process) do |forked|
   if forked
     # We're in smart spawning mode, so...
     # Close duplicated memcached connections - they will open themselves
     CACHE.reset
   end
 end
 # In case you're not running under Passenger (i.e. devmode with mongrel)
 rescue NameError => error
end
