require 'resque'

task "resque:setup" => :environment do
  # FIX FOR "PG::Error: ERROR: prepared statement "a1" already exists"
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
