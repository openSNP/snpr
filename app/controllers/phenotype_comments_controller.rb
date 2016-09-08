class PhenotypeCommentsController < ApplicationController
  before_filter :require_user

  def new
    @phenotype_comment = PhenotypeComment.new
    @title = 'Add comment'

    respond_to do |format|
      format.html
      format.xml { render :xml => @phenotype }
    end
  end

  def create
    @phenotype_comment = PhenotypeComment.new(phenotype_comment_params)
    if @phenotype_comment.comment_text.index(/\A(\@\#\d*\:)/) == nil
      @phenotype_comment.reply_to_id = -1
    else

      @potential_reply_id = @phenotype_comment.comment_text.split()[0].chomp(':').gsub('@#','').to_i
      if PhenotypeComment.find_by_id(@potential_reply_id) != nil
        @phenotype_comment.reply_to_id = @potential_reply_id
      else
        @phenotype_comment.reply_to_id = -1
      end

      @phenotype_comment.comment_text = @phenotype_comment.comment_text.gsub(/\A(\@\#\d*\:)/,'')
    end
    @phenotype_comment.user_id = current_user.id
    @phenotype_comment.phenotype_id = params[:phenotype_comment][:phenotype_id]
    if @phenotype_comment.save
      if @phenotype_comment.reply_to_id != -1
        @reply_user = PhenotypeComment.find_by_id(@phenotype_comment.reply_to_id).user
        if@reply_user != nil
          if @reply_user.message_on_phenotype_comment_reply == true
            UserMailer.new_phenotype_comment(@phenotype_comment,@reply_user).deliver_later
          end
        end
      end
      redirect_to '/phenotypes/' +@phenotype_comment.phenotype_id.to_s+'#comments', :notice => 'Comment succesfully created.'
    else
      render :action => 'new'
    end
  end

  def phenotype_comment_params
    params.require(:phenotype_comment).permit(:subject, :comment_text, :phenotype_id)
  end
end
