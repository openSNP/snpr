class MessagesController < ApplicationController
  def new
	  #create the message
	  # m = Message.new()
	  # m = bla
	  #
	  # m.send_message(id1, id2)
	  #send the message
  end

  def show
	  @message = Message.find_by_id(params[:id])
	  @from = User.find_by_id(@message.from_id)
  end

end
