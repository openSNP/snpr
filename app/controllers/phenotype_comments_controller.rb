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
		if @phenotype_comment.comment_text.index("@") == nil
			@phenotype_comment.reply_to_id = -1
		else
			@all_comments = Phenotype.find_by_id(@phenotype_comment.snp_id).phenotype_comments
			@referred_to = @phenotype_comment.comment_text.split()[0].chomp(":").gsub("@","")
			@phenotype_comment.reply_to_id = @all_comments.find_by_user_id(User.find_by_name(@referred_to).id).id
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
