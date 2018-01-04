# frozen_string_literal: true

class AchievementsController < ApplicationController
  def show
    @achievement = Achievement.find(params[:id])
    @title = 'Achievements'
  end
end
