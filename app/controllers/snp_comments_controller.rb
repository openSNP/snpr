class SnpCommentsController < ApplicationController
  before_filter :require_user

  def new
		@snp_comment = SnpComment.new
		# current user is always stored in the method 'current_user',
		# not in the variable '@current_user'
		@title = "Add comment"

		respond_to do |format|
			format.html
			format.xml { render :xml => @snp }
		end
	end

	def create
		@snp_comment = SnpComment.new(params[:snp_comment])
		if @snp_comment.comment_text.index(/\A(\@\#\d*\:)/) == nil
			@snp_comment.reply_to_id = -1
		else
			# find the comment this post links to
			# user to which we're talking
			@snp_comment.reply_to_id = @snp_comment.comment_text.split()[0].chomp(":").gsub("@#","").to_i
			@snp_comment.comment_text = @snp_comment.comment_text.gsub(/\A(\@\#\d*\:)/,"")
		end
		@snp_comment.user_id = current_user.id
		@snp_comment.snp_id = params[:snp_comment][:snp_id]
  		if @snp_comment.save
			redirect_to "/snps/"+@snp_comment.snp_id.to_s + "#comments", :notice => 'Comment succesfully created.'
		else
			render :action => "new"
  		end
  	end

end
