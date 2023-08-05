SimpleCov.start('rails') do
  add_filter "/lib/capistrano/"
  enable_coverage :branch
  primary_coverage :branch
  refuse_coverage_drop :branch
end
