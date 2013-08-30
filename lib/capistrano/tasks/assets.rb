namespace :deploy do
  task :precompile_assets do
    run "cd '#{release_path}'; RAILS_ENV=production rake assets:precompile"
  end
  after "deploy:create_shared_dirs", "deploy:precompile_assets"
end
