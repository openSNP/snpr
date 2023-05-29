# frozen_string_literal: true
class SnpCommentsController < ApplicationController
  before_action :require_user

  def new
    @snp_comment = SnpComment.new
    # current user is always stored in the method 'current_user',
    # not in the variable '@current_user'
    @title = 'Add comment'

    respond_to do |format|
      format.html
      format.xml { render xml: @snp }
    end
  end

  def create
    @snp_comment = SnpComment.new(comment_params)
    if @snp_comment.comment_text.index(/\A(\@\#\d*\:)/) == nil
      @snp_comment.reply_to_id = -1
    else
      # find the comment this post links to
      # user to which we're talking

      @potential_reply_id = @snp_comment.comment_text.split()[0].chomp(':').gsub('@#', '').to_i
      if SnpComment.find_by_id(@potential_reply_id) != nil
        @snp_comment.reply_to_id = @potential_reply_id
      else
        @snp_comment.reply_to_id = -1
      end

      @snp_comment.comment_text = @snp_comment.comment_text.gsub(/\A(\@\#\d*\:)/, '')
    end
    @snp_comment.user_id = current_user.id
    @snp_comment.snp_id = params[:snp_comment][:snp_id]
    if @snp_comment.save
      if @snp_comment.reply_to_id != -1
        @reply_user = SnpComment.find_by_id(@snp_comment.reply_to_id).user
        if @reply_user
          if @reply_user.message_on_snp_comment_reply
            UserMailer.new_snp_comment(@snp_comment,@reply_user).deliver_later
          end
        end
      end
      redirect_to "/snps/#{@snp_comment.snp_id}#comments", notice: 'Comment successfully created.'
    else
      render action: 'new'
    end
  end

  private

  def comment_params
    params.require(:snp_comment).permit(:snp_id, :subject, :comment_text)
  end
end
