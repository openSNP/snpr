class PhenotypesController < ApplicationController
    before_filter :require_user

	def show
		@phenotype = Phenotype.find(params[:id])
		@variations = @phenotype.variations
		@user = current_user
	
		@title = "Phenotypes"
		respond_to do |format|
			format.html
			format.xml
		end
	end

	def edit
		@variations = Phenotype.find(params[:id]).variations
		@title = "Edit your Phenotypes"

		respond_to do |format|
			format.html
			format.xml
			end
		end
	end

end
