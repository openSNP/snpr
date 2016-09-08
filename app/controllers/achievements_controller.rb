class AchievementsController < ApplicationController

def show
  @achievement = Achievement.find(params[:id])

  @title = 'Achievements'
  respond_to do |format|
    format.html
    format.xml
  end
end

end
