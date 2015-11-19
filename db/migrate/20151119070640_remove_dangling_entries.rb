class RemoveDanglingEntries < ActiveRecord::Migration
  def up
    UserSnp.find_each do |us|
      if Snp.find_by_name(us.snp_name).nil? || Genotype.find_by_id(us.id).nil?
        UserSnp.destroy(us.id)
      end
    end

    %w(UserPhenotype Homepage UserPicturePhenotype UserAchievement).each do |name|
      name = name.constantize
      name.find_each do |u|
        if User.find_by_id(u.user_id).nil?
          name.destroy(u.id)
        end
      end 
    end
    # things that aren't dangling (I checked):
    # All SNPs have UserSNPs
    # All Genotypes have existing Users
    # All FitbitProfiles have Users
  end
end
