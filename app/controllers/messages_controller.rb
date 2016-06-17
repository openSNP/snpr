class MessagesController < ApplicationController
  before_filter :require_user
  before_filter :require_owner, only: [:show, :destroy]

  def new
    @title = 'New message'

    @message = Message.new
    @users = User.all
    if params[:message]
      @answering = Message.find_by_id(params[:message])
      if @answering.from_id != current_user.id && @answering.to_id != current_user.id
        @answering = nil
      end
    end
  end

  def create
    @message = Message.new(message_params)

    if @message.save && @message.send_message(@message.from_id, @message.to_id)
      flash[:notice] = 'Message sent'
      redirect_to "/users/#{current_user.id}#messages"
    else
      render action: 'new'
    end
  end

  def show
    @message = Message.find_by_id(params[:id])
    if !User.find_by_id(@message.from_id).nil?
      @from = User.find_by_id(@message.from_id)
    else
      @from = 'Deleted User'
    end

    if !User.find_by_id(@message.to_id).nil?
      @to = User.find_by_id(@message.to_id)
    else
      @to = 'Deleted User'
    end
    @message.update_attributes user_has_seen: true
  end

  def destroy
    message = Message.where(from_id: current_user.id, id: params[:id]).first
    if message
      message.destroy
      flash[:notice] = 'Message deleted'
      redirect_to '/users/' + current_user.id.to_s + '#messages'
    else
      render text: 'Unauthorized', status: :unauthorized
    end
  end

  private

  def require_owner
    return if current_user.id == Message.find(params[:id]).user_id
    store_location
    if current_user
      flash[:warning] = 'Oops! Thats none of your business'
      redirect_to controller: 'users', action: 'show', id: current_user.id
    else
      flash[:notice] = 'You need to be logged in'
      redirect_to '/signin'
    end
  end

  def message_params
    params.require(:message).permit(:to_id, :subject, :body).merge(
      from_id: current_user.id,
      user_id: current_user.id,
      user_has_seen: true,
      sent: true,
    )
  end
end
