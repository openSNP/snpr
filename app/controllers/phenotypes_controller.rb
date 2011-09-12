class PhenotypesController < ApplicationController
    before_filter :require_user
	  helper_method :sort_column, :sort_direction
	
	def index
	  @phenotypes = Phenotype.order(sort_column + " " + sort_direction)
	  @phenotypes_paginate = @phenotypes.paginate(:page => params[:page],:per_page => 10)
    respond_to do |format|
			format.html
			format.xml 
		end
  end
  
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
	  if Phenotype.find_by_characteristic(params[:phenotype][:characteristic]) == nil
		  @phenotype = Phenotype.create(params[:phenotype])
	  else
	    @phenotype = Phenotype.find_by_characteristic(params[:phenotype][:characteristic])
		end
		
		# check if phenotype exists
		#if Phenotype.find_by_characteristic(@phenotype.characteristic) == nil
		#	@phenotype.save
    #end

		if @phenotype.known_phenotypes.include?(params[:user_phenotype][:variation]) == false
		  @phenotype.known_phenotypes << params[:user_phenotype][:variation]
	  end
	  @phenotype.save
        
		@user_phenotype = UserPhenotype.new(:user_id => current_user.id, :phenotype_id => @phenotype.id, :variation => params[:user_phenotype][:variation])
	
		if @user_phenotype.save
			redirect_to current_user
		else
			redirect_to :action => "new", :notice => "Something went wrong in creating the phenotype"
		end
	end
  
	def show
		#@phenotypes = Phenotype.where(:user_id => current_user.id).all
		#@title = "Phenotypes"
		@phenotype = Phenotype.find(params[:id])
		@comments = PhenotypeComment.where(:phenotype_id => params[:id]).all(:order => "created_at ASC")
		@phenotype_comment = PhenotypeComment.new
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
	
	  private
	  
		def sort_column
			Phenotype.column_names.include?(params[:sort]) ? params[:sort] : "characteristic"
	  end
	  
	  def sort_direction
		%w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	  end
end