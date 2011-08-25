class SnpCommentsController < ApplicationController
  before_filter :require_user

  def new
		@snp_comment = SnpComment.new
		# current user is always stored in the method 'current_user',
		# not in the variable '@current_user'
		@snp_comment.user = current_user
		@title = "Add comment"

		respond_to do |format|
			format.html
			format.xml { render :xml => @snp }
		end
	end
		def create
  		@snp_comment = SnpComment.new()
  		@snp_comment.user_id = current_user.id
  		if @snp_comment.save
        format.html { redirect_to(current_user, :notice => 'Genotype was successfully uploaded! Parsing might take a couple of minutes.') }
  		  format.xml { render :xml => @snp, :status => :created, :location => @snp }
  	  else
  	    format.html { render :action => "new" }
  			format.xml { render :xml => @snp_comment.errors, :status => :unprocessable_entity }
  		end
  	end
end
