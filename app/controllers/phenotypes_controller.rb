class PhenotypesController < ApplicationController

	def show
		@phenotype = Phenotype.find(params[:id])
		@variations = @phenotype.variations
		@user = User.find_by_id(@phenotype.user_id)
	
		@title = "Phenotypes"
		respond_to do |format|
			format.html
			format.xml
		end
	end

end
