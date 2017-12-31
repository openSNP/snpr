# frozen_string_literal: true
class IndexController < ApplicationController
  def index
    if current_user
      redirect_to current_user
    end
  end
end
