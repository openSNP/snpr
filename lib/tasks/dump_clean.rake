namespace :dump do
  desc 'clean everything in public/zip older than 2 days'
  task clean: :environment do
    dir = File.join(Rails.root, 'public/data/zip')
    # Don't ever delete the link and what is linked to
    datadump = File.join(dir, 'opensnp_datadump.current.zip')
    forbidden_files = [datadump]
    if File.file? datadump
      forbidden_files << File.readlink(datadump)
    end

    Dir.entries(dir).each do |f|
      f = File.join(dir, f)
      # Has to be older than 2 days, don't delete important files, only delete archives
      if (get_file_age_in_days(f) > 2) and (not forbidden_files.include? f) and (f.ends_with? 'zip')
        File.delete(f)
      end
    end
  end
end

def get_file_age_in_days(file)
  (Time.now - File.mtime(file)) / 1.day
end
