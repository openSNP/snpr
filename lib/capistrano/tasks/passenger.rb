# frozen_string_literal: true
namespace :passenger do
  task :restart do
    run("cd #{current_path}; touch tmp/restart.txt")
  end
end
