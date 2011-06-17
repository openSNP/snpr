class User < ActiveRecord::Base

	acts_as_authentic # call on authlogic

	has_one :phenotypes
	has_many :genotypes
end
