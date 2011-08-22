class User < ActiveRecord::Base
    attr_accessible :phenotypes_attributes, :variation, :characteristic, :name, :password_confirmation, :password, :email, :description, :homepages, :homepages_attributes
	
	acts_as_authentic # call on authlogic
    after_create :make_standard_phenotypes, :make_empty_homepage

	# dependent so stuff gets destroyed on delete
	has_many :user_phenotypes, :dependent => :destroy
	has_many :genotypes, :dependent => :destroy
	# user_snps needs some extra-logic to decrease the counters
	has_many :user_snps, :dependent => :destroy
	has_many :snps, :through => :user_snps
	has_many :homepages, :dependent => :destroy

	# needed to edit several user_phenotypes at once, add and delete, and not empty
	accepts_nested_attributes_for :homepages, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true
	accepts_nested_attributes_for :user_phenotypes, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true


	def deliver_password_reset_instructions!
		reset_perishable_token!
		Notifier.deliver_password_reset_instructions(self)
	end

   def check_if_phenotype_exists(charact)
	   if Phenotype.find_by_characteristic(charact) != nil
		   return true
	   else
		   return false
	   end
   end

   def check_and_make_standard_phenotypes(charact)
	   if check_if_phenotype_exists(charact) == true
		   @phen_id = Phenotype.find_by_characteristic(charact).id
		   UserPhenotype.create(:phenotype_id => @phen_id, :variation => '', :user_id => id)
	   else
		   @phen_id = Phenotype.create(:characteristic => charact).id
     	   UserPhenotype.create(:phenotype_id => @phen_id, :variation => '', :user_id => id)
	   end
   end
  	
   def make_standard_phenotypes
	   check_and_make_standard_phenotypes('Hair color')
	   check_and_make_standard_phenotypes('Eye color')
	   check_and_make_standard_phenotypes('Skin color')
	   check_and_make_standard_phenotypes('Blood type')
   end

   def make_empty_homepage
	   Homepage.create(:user_id => id, :url => "Enter your URL", :description => "Enter your description")
   end
end
