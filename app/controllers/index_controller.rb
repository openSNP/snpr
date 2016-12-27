# frozen_string_literal: true
class IndexController < ApplicationController
  def index
    if current_user
      redirect_to current_user
    else
      respond_to do |format|
  		  format.html
  		  format.xml 
  	  end
    end
  end
end