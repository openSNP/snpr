def ln(src, dst)
  run("ln -snf '#{src}' '#{dst}'")
end

def mkdir(path)
  run("[ -d '#{path}' ] || mkdir -p '#{path}'")
end

def rake(command)
  run("cd #{current_path}; RAILS_ENV=production bundle exec rake #{command}")
end
