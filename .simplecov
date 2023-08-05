SimpleCov.start('rails') do
  refuse_coverage_drop
  add_filter "/lib/capistrano/"
end
