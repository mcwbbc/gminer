# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
config.log_level = :info

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!
config.middleware.use "Rack::Bug"
config.action_mailer.delivery_method = :smtp

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
