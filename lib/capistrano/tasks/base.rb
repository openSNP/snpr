namespace :deploy do
  task :set_symlinks do
    ln("#{shared_path}/secret_key_base", "#{release_path}/secret_key_base")
    ln("#{shared_path}/config/app_config.yml", "#{release_path}/config/app_config.yml")
    ln("#{shared_path}/config/database.yml", "#{release_path}/config/database.yml")
    ln("#{shared_path}/config/secret_token", "#{release_path}/secret_token")
    ln("#{shared_path}/config/mail_username.txt", "#{release_path}/mail_username.txt")
    ln("#{shared_path}/config/mail_password.txt", "#{release_path}/mail_password.txt")
    ln("#{shared_path}/config/key_mendeley.txt", "#{release_path}/key_mendeley.txt")
    ln("#{shared_path}/config/key_plos.txt", "#{release_path}/key_plos.txt")
    ln("#{shared_path}/config/newrelic.yml", "#{release_path}/config/newrelic.yml")
    ln("#{shared_path}/data", "#{release_path}/public/data")
    mkdir("#{shared_path}/data/zip")
    mkdir("#{shared_path}/assets")
    ln("#{shared_path}/assets", "#{release_path}/public/assets")
    ln("#{shared_path}/config/exceptional.yml", "#{release_path}/config/exceptional.yml")
  end
  after "deploy:create_shared_dirs", "deploy:set_symlinks"

  task :create_shared_dirs do
    mkdir("#{shared_path}/config")
  end
  after "deploy:update_code", "deploy:create_shared_dirs"
end
