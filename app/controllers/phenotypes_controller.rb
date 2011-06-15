class PhenotypesController < ApplicationController

	def change
		# let's hope this works
		@variations = Phenotype.find_by_user_id(User.find(params[:id]))

		respond_to do |format|
			format.html
			format.xml
		end
	end

end
