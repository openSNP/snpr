class PhenotypesController < ApplicationController

	def show
		@variations = Phenotype.find(params[:id]).variations
		@user = User.find_by_id(Phenotype.find(params[:id]).user_id)
	
		@title = "Phenotypes"
		respond_to do |format|
			format.html
			format.xml
		end
	end

end
