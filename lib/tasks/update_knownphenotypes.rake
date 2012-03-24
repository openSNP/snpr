# update Phenotype.known_phenotypes to remove empty/no longer used variations

namespace :phenotypes do
  desc "update Phenotype.known_phenotypes to remove empty/no longer used variations"
  task :update_known_phenotypes => :environment do
    Phenotype.find_each do |p|
      variation_array = []
      p.user_phenotypes.each do |u|
        if variation_array.include?(u.variation) == false
          variation_array << u.variation
        end
      end
      p.known_phenotypes = variation_array
      p.save
    end
  end
end
