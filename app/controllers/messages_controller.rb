class MessagesController < ApplicationController

  before_filter :require_user
  before_filter :require_owner, only: [ :show, :destroy ]
  
  def new
	  #create the message
	  @message = Message.new
	  @title = "New message"
      @users = User.all
	  # ideally, we would kick out the current_user however, this generates crashes when there are only two users (function "map" doesn't work on a single object)
      if params[:message] 
         @answering = Message.find_by_id(params[:message])
         @allowed = true
         if @answering.from_id != current_user.id and @answering.to_id != current_user.id 
             @allowed = false
         end
      end
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

	  if params[:user] != nil
		  @message.to_id = params[:user][:id]
	  end

	  if @message.save and @message.send_message(@message.from_id, @message.to_id)
		  flash[:notice] = "Message sent!"
		  redirect_to "/users/" + current_user.id.to_s + "#messages"
	  else
		  respond_to do |format|
			  format.html { render :action => "new" }
			  format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
		  end
	  end
  end

    def show
    @message = Message.find_by_id(params[:id])
    if User.find_by_id(@message.from_id) != nil
        @from = User.find_by_id(@message.from_id)
    else
        @from = "Deleted User"
    end
    
    if User.find_by_id(@message.to_id) != nil 
        @to = User.find_by_id(@message.to_id)
    else
        @to = "Deleted User"
    end
    @message.update_attributes :user_has_seen => true
  end

  def destroy
	  message = Message.find_by_id(params[:id])
	  if message.destroy
		  flash[:notice] = "Message deleted."
		  redirect_to "/users/" + current_user.id.to_s + "#messages"
	  end
  end

  def require_owner
    unless current_user.id == Message.find_by_id(params[:id]).user_id
      store_location
		  if current_user
		    flash[:warning] = "Oops! Thats none of your business"
		    redirect_to :controller => "users", :action => "show", :id => current_user.id 
	    else
	      flash[:notice] = "You need to be logged in"
	      redirect_to "/signin"
      end
		  return false
	  end
  end

end
