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
		if @phenotype_comment.comment_text.index(/\A(\@\#\d*\:)/) == nil
			@phenotype_comment.reply_to_id = -1
		else
			@phenotype_comment.reply_to_id = @phenotype_comment.comment_text.split()[0].chomp(":").gsub("@#","").to_i
			@phenotype_comment.comment_text = @phenotype_comment.comment_text.gsub(/\A(\@\#\d*\:)/,"")
		end
		@phenotype_comment.user_id = current_user.id
		@phenotype_comment.phenotype_id = params[:phenotype_comment][:phenotype_id]
  		if @phenotype_comment.save
			redirect_to "/phenotypes/"+@phenotype_comment.phenotype_id.to_s+"#comments", :notice => 'Comment succesfully created.'
		else
			render :action => "new" 
  		end
  	end

end
