class User < ActiveRecord::Base
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  attr_accessible :user_phenotypes_attributes, :variation, :characteristic, :name, :password_confirmation, :password, :email, :description, :homepages, :homepages_attributes,:avatar
	
	
	acts_as_authentic # call on authlogic
	after_create :make_standard_phenotypes

	# dependent so stuff gets destroyed on delete
	has_many :user_phenotypes, :dependent => :destroy
	has_many :phenotypes, :through => :user_phenotypes
	has_many :genotypes, :dependent => :destroy
	# user_snps needs some extra-logic to decrease the counters
	has_many :user_snps, :dependent => :destroy
	has_many :snps, :through => :user_snps
	has_many :homepages, :dependent => :destroy
	has_many :messages
	has_many :user_achievements, :dependent => :destroy
	has_many :achievements, :through => :user_achievements

	# needed to edit several user_phenotypes at once, add and delete, and not empty
	accepts_nested_attributes_for :homepages, :allow_destroy => true
	accepts_nested_attributes_for :user_phenotypes, :allow_destroy => true

	searchable do
		text :description, :name, :email
	end

	def deliver_password_reset_instructions!
		reset_perishable_token!
		Notifier.deliver_password_reset_instructions(self)
	end

   def check_if_phenotype_exists(charact)
		 # checks so we don't create duplicate phenotypes
	   if Phenotype.find_by_characteristic(charact) != nil
		   return true
	   else
		   return false
	   end
   end

   def check_and_make_standard_phenotypes(charact)
		 # checks whether phenotype exists, creates one if doesn't,
		 # creates fitting user_phenotype in both cases
	   if check_if_phenotype_exists(charact) == true
		   @phen_id = Phenotype.find_by_characteristic(charact).id
		   UserPhenotype.create(:phenotype_id => @phen_id, :variation => '', :user_id => id)
	   else
		   @phen_id = Phenotype.create(:characteristic => charact,:known_phenotypes => []).id
     	   UserPhenotype.create(:phenotype_id => @phen_id, :variation => '', :user_id => id)
	   end
   end
  	
   def make_standard_phenotypes
	   check_and_make_standard_phenotypes('Hair color')
	   check_and_make_standard_phenotypes('Eye color')
	   check_and_make_standard_phenotypes('Skin color')
	   check_and_make_standard_phenotypes('Blood type')
   end

   def check_whether_user_has_phenotype_award_and_create(pheno_count, award)
		 # checks for a given award-type and creates user_award if not existing
		 
		 # check for number of phenotypes
		 @number_of_phenotypes = current_user.phenotypes.all.count
     # check what achievements are already awarded
		 @achievements = current_user.achievements
		 if @number_of_phenotypes >= pheno_count and @achievements.find_by_award(award) == nil
        @award = Achievement.find_by_award(award)
				UserAchievement.create(:user_id => current_user.id, :achievement_id => @award.id)
		 end
	 end

   def check_and_award_phenotypes_achievements
		 # checks whether the user has a certain achievement in the area of phenotypes
		 # awards achievements if not
		 #
		 # Method is called on phenotype-creation
		 # (There is a method for phenotype, snps, etc. because else I'd
		 # have to parse several tables, which would take too much time/power)
		 
		 # 4 standard phenotypes + 5 new = 9 phenotypes = 1 award 
		 # this does not award if user deleted standard-phenotypes!
		 check_whether_user_has_phenotype_award_and_create(9, "Entered 5 additional phenotypes")
		 check_whether_user_has_phenotype_award_and_create(14, "Entered 10 additional phenotypes")
		 check_whether_user_has_phenotype_award_and_create(24, "Entered 20 additional phenotypes")
		 check_whether_user_has_phenotype_award_and_create(54, "Entered 50 additional phenotypes")
		 check_whether_user_has_phenotype_award_and_create(104, "Entered 100 additional phenotypes")
	 end


end
