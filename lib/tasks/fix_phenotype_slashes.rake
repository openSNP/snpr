# frozen_string_literal: true
# some of the user-phenotypes have "::" instead of "/", fix this

namespace :phenotypes do
  desc "fixes broken phenotype-variations with '::' instead of '/'"
  task :fix_broken_slashes => :environment do
    UserPhenotype.where("variation like '%::%'").includes(:phenotype).find_each do |up|
      puts "Updating #{up.phenotype.characteristic}, #{up.variation}"
      # replace :: by /
      new_variation = up.variation.gsub("::","/")
      up.update_attributes(:variation => new_variation)
    end
  end
end
