class PhenotypesController < ApplicationController
    before_filter :require_user
	
	def new
		@phenotype = Phenotype.new
		@user_phenotype = UserPhenotype.new
		@title = "Create a new phenotype"

		respond_to do |format|
			format.html
			format.xml
		end
	end

	def create
		@phenotype = Phenotype.new(params[:phenotype])
		# check if phenotype exists
		if Phenotype.find_by_characteristic(@phenotype.characteristic) == nil
			@phenotype.save
		end
        
		@user_phenotype = UserPhenotype.new(:user_id => current_user.id, :phenotype_id => @phenotype.id, :variation => params[:user_phenotype][:variation])
		if @user_phenotype.save
			redirect_to current_user
		else
			redirect_to :action => "new", :notice => "Something went wrong in creating the phenotype"
		end
	end

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
		@phenotypes = Phenotype.where(:user_id => current_user.id).all
		respond_to do |format|
			format.html
			format.xml
		end
	end
end
