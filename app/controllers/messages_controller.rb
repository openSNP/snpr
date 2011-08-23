class MessagesController < ApplicationController
  def new
	  #create the message
	  @message = Message.new
	  @title = "New message"
	  @users = User.all # .delete(current_user) 
	  # ideally, we would kick out the current_user however, this generates crashes when there are only two users (function "map" doesn't work on a single object)
	  
	  respond_to do |format|
		  format.html
		  format.xml { render :xml => @message }
	  end
  end

  def create
	  @message = Message.new(params[:message])
	  @message.user_id = current_user.id
	  @message.user_has_seen = true
	  @message.from_id = current_user.id
      @message.sent = true
	  @message.to_id = params[:user][:id]


	  if @message.save and @message.send_message(@message.from_id, @message.to_id)
		  flash[:notice] = "Message sent!"
		  redirect_to current_user
	  else
		  respond_to do |format|
			  format.html { render :action => "new" }
			  format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
		  end
	  end
  end

  def show
	  @message = Message.find_by_id(params[:id])
	  @from = User.find_by_id(@message.from_id)
	  @to = User.find_by_id(@message.to_id)
	  @message.update_attributes :user_has_seen => true
  end

end
