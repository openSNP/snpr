# creates the paths needed

%w[
  public/data/zip

].each do |path|
  dirs = path.split('/')
  dirs.size.times do |i|
    new_path = Rails.root.to_s + '/' + dirs[0..i].join('/')
    Dir.mkdir(new_path) unless Dir.exist?(new_path)
  end
end
