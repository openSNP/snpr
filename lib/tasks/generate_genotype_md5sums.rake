namespace :genotypes do
  desc 'calculate md5sums for genotypes'
  task update: :environment do
    require 'digest'
    @genotypes = Genotype.all
    @genotypes.each do |g|
      # get filename
      filename = ::Rails.root.to_s + '/public/data/' + g.fs_filename
      puts 'MD5 for file ' + filename
      md5 = Digest::MD5.file(filename).to_s
      puts 'Md5 is'
      puts md5
      g.update_attributes(md5sum: md5)
      puts 'Updated!'
    end
  end
end
