require 'resque/pool/tasks'
require 'resque'

task "resque:setup" => :environment do
  # FIX FOR "PG::Error: ERROR: prepared statement "a1" already exists"
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  # and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
  end
end

