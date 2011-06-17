class User < ActiveRecord::Base

	acts_as_authentic # call on authlogic

	has_one :phenotypes
	has_many :genotypes


	def deliver_password_reset_instructions!
		reset_perishable_token!
		Notifier.deliver_password_reset_instructions(self)
	end
end
