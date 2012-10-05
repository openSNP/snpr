server "opensnp.org", :app, :web, :primary => true
set :deploy_to, "var/www/snpr"


namespace :deploy do
    task :start do

    end

    task :stop do
    end

    task :restart do
        run "touch /var/www/snpr/tmp/restart.txt"
    end

end
