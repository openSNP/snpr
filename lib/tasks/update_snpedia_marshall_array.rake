require 'media_wiki'

namespace :snpedia do
  desc 'update snpedia array'
  task download: :environment do
    file = Rails.root.join('marshalled_snpedia_array')

    old = Marshal.load(File.open(file))
    puts "There are #{old.length} SNPs in the old array"

    mw = MediaWiki::Gateway.new('http://bots.snpedia.com/api.php')
    puts 'Downloading all SNPs'
    new = mw.category_members('Category:Is_a_snp')
    new.map!(&:downcase)

    puts "There are #{new.length} SNPs in the new array, dumping now"
    File.open(file, 'wb') do |f|
      f.write Marshal.dump(new)
    end
    puts 'Done!'
  end
end
