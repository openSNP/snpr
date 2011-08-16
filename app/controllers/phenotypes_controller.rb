class PhenotypesController < ApplicationController
    before_filter :require_user

	def show
		@phenotypes = Phenotype.where(:user_id => current_user.id).all
	
		@title = "Phenotypes"
		respond_to do |format|
			format.html
			format.xml
		end
	end

	def edit
		@title = "Edit your Phenotypes"
		@phenotype = Phenotype.find_by_id(params[:phenotype])

		respond_to do |format|
			format.html
			format.xml
		end
	end
end
