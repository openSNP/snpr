namespace :rubocop do
  desc 'Run rubocop'
  task :run do
    sh("bundle exec rubocop -D") {}
  end

  desc "Run Rubocop, don't show TODOs"
  task :run_without_todos do
    config = YAML.load(File.read('.rubocop.yml'))
    todos = YAML.load(File.read('.rubocop_todo.yml'))
    tmpfile = Tempfile.new(%w(snpr-rubocop .yml))
    tmpfile.write(config.merge(todos).to_yaml)

    sh("bundle exec rubocop -D --config #{tmpfile.path}") {}
  end

  desc 'Generate new TODO file'
  task :generate_todos do
    sh("bundle exec rubocop --auto-gen-config") {}
  end
end
