class User < ActiveRecord::Base
    attr_accessible :phenotypes_attributes, :variation, :characteristic, :name, :password_confirmation, :password, :email, :description
	

	acts_as_authentic # call on authlogic

	# dependent so stuff gets destroyed on delete
	has_many :phenotypes, :dependent => :destroy
	has_many :genotypes, :dependent => :destroy
	# user_snps needs some extra-logic to decrease the counters
	has_many :user_snps, :dependent => :destroy

	# needed to edit several phenotypes at once, add and delete, and not empty
	accepts_nested_attributes_for :phenotypes, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true

	def deliver_password_reset_instructions!
		reset_perishable_token!
		Notifier.deliver_password_reset_instructions(self)
	end
end
