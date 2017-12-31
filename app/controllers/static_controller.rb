# frozen_string_literal: true
class StaticController < ApplicationController
  def index
    @title = 'Welcome'
  end

  def faq
    @title = 'FAQ'
  end

  def press
    @title = 'openSNP in the press'
  end
end
