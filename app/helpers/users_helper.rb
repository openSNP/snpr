module UsersHelper

	def returnArrayPhenotypes(user)
		Phenotype.find_by_user_id(user.user_id).variations
	end
end
		
