class PhenotypesController < ApplicationController
    before_filter :require_user

	def show
		@all_phenotypes = Phenotype.all
		@phenotype = Phenotype.find_by_user_id(params[:id])
	
		@title = "Phenotypes"
		respond_to do |format|
			format.html
			format.xml
		end
	end

	def edit
		@title = "Edit your Phenotypes"

		respond_to do |format|
			format.html
			format.xml
		end
	end
end
