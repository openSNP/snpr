class UserPhenotypesController < ApplicationController
  before_filter :require_user

  def new
		@user_phenotype = UserPhenotype.new
		@title = "Add variation"

		respond_to do |format|
			format.html
			format.xml { render :xml => @phenotype }
		end
	end

	def create
		@user_phenotype = UserPhenotype.new(params[:user_phenotype])
		@user_phenotype.user_id = current_user.id
		@user_phenotype.phenotype_id = params[:user_phenotype][:phenotype_id]
		
		@phenotype = Phenotype.find_by_id(params[:user_phenotype][:phenotype_id])
		if @phenotype.known_phenotypes.include?(params[:user_phenotype][:variation]) == false
		  @phenotype.known_phenotypes << params[:user_phenotype][:variation]
	  end
	  @phenotype.save
		
  		if @user_phenotype.save
			redirect_to "/phenotypes/"+@user_phenotype.phenotype_id.to_s, :notice => 'Variation successfully saved'
		else
			render :action => "new" 
  		end
  	end

end