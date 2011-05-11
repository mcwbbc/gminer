#############################################################
#	Other Tasks
#############################################################

namespace :deploy do
  namespace :web do
    desc "Serve up a custom maintenance page."
    task :disable, :roles => :web do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }

      reason      = ENV['REASON']
      deadline    = ENV['UNTIL']

      template = File.read("app/views/layouts/maintenance.html.erb")
      page = ERB.new(template).result(binding)

      put page, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end
