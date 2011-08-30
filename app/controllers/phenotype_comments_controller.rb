class PhenotypeCommentsController < ApplicationController
  before_filter :require_user

  def new
		@phenotype_comment = PhenotypeComment.new
		@title = "Add comment"

		respond_to do |format|
			format.html
			format.xml { render :xml => @phenotype }
		end
	end

	def create
		@phenotype_comment = PhenotypeComment.new(params[:phenotype_comment])
		@phenotype_comment.user_id = current_user.id
		@phenotype_comment.phenotype_id = params[:phenotype_comment][:phenotype_id]
  		if @phenotype_comment.save
			format.html { redirect_to(current_user, :notice => 'Comment succesfully created.') }
			format.xml { render :xml => @phenotype, :status => :created, :location => @phenotype }
		else
			format.html { render :action => "new" }
  			format.xml { render :xml => @phenotype_comment.errors, :status => :unprocessable_entity }
  		end
  	end

end
