namespace :solr do
  task :start do
    rake("sunspot:solr:start")
  end

  task :stop do
    begin
      rake("sunspot:solr:stop")
    rescue => e
      puts "Couldn't stop Solr. May have not been running... (#{e.class})"
    end
  end

  task :restart do
  end
  after "unicorn:restart", "solr:restart"
  after "solr:restart", "solr:stop"
  after "solr:restart", "solr:start"
end
