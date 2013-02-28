Dir["#{::Rails.root.to_s}/app/jobs/*.rb"].each { |file| require file }

# FIX for: "PG::Error: ERROR: prepared statement "a1" already exists"
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
