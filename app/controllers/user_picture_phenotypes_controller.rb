# frozen_string_literal: true
class UserPicturePhenotypesController < ApplicationController
  before_filter :require_user

  def new
    @user_phenotype = UserPicturePhenotype.new
    @title = 'Add variation'

    if params[:phenotype]
      @phenotype = PicturePhenotype.find(params[:picture_phenotype])
    end

    if params[:js_modal]
      @js_modal = true
    end

    respond_to do |format|
      format.js
      format.html
      format.xml { render xml: @phenotype }
    end
  end

  def edit
    @user_phenotype = UserPicturePhenotype.find_by_user_id_and_picture_phenotype_id(current_user.id,params[:user_picture_phenotype][:picture_phenotype_id])
    @user_phenotype.phenotype_picture = params[:user_picture_phenotype][:phenotype_picture]
    @user_phenotype.save()
    redirect_to '/picture_phenotypes/'+@user_phenotype.picture_phenotype_id.to_s, notice: 'Variation successfully updated'
  end

  def delete
    @user_phenotype = UserPicturePhenotype.find_by_id(params[:id])
    @phenotype = @user_phenotype.picture_phenotype
    if @user_phenotype.user_id == current_user.id
      @user_phenotype.delete()
      redirect_to "/picture_phenotypes/"+@user_phenotype.picture_phenotype_id.to_s, notice: 'Variation successfully deleted'
    else
      redirect_to '/picture_phenotypes/'+@user_phenotype.picture_phenotype_id.to_s, notice: 'Whops, something went wrong'
    end
  end


  def create
    @user_phenotype = current_user.user_picture_phenotypes.new(
      phenotype_picture: params[:user_picture_phenotype][:phenotype_picture])
    @user_phenotype.phenotype_picture = params[:user_picture_phenotype][:phenotype_picture]
    @user_phenotype.user_id = current_user.id
    @user_phenotype.picture_phenotype_id = params[:user_picture_phenotype][:picture_phenotype_id]

    if params[:js_modal]
      @js_modal = true
    else
      @js_modal = false
    end

    if UserPicturePhenotype.find_by_picture_phenotype_id_and_user_id(@user_phenotype.picture_phenotype_id,@user_phenotype.user_id) == nil

      @phenotype = PicturePhenotype.find_by_id(params[:user_picture_phenotype][:picture_phenotype_id])

      if @user_phenotype.save
        #check for new achievements
        check_and_award_additional_phenotypes(1, "Entered first phenotype")
        check_and_award_additional_phenotypes(5, "Entered 5 additional phenotypes")
        check_and_award_additional_phenotypes(10, "Entered 10 additional phenotypes")
        check_and_award_additional_phenotypes(20, "Entered 20 additional phenotypes")
        check_and_award_additional_phenotypes(50, "Entered 50 additional phenotypes")
        check_and_award_additional_phenotypes(100, "Entered 100 additional phenotypes")

        if @js_modal == true
          redirect_to '/users/' + current_user.id.to_s
        else
          redirect_to '/picture_phenotypes/' + @user_phenotype.picture_phenotype_id.to_s, notice: 'Variation successfully saved'
        end
      else
        flash[:warning] = 'Please enter a variation'
        redirect_to '/users/' + current_user.id.to_s
      end
    else
      redirect_to '/picture_phenotypes/' + @user_phenotype.picture_phenotype_id.to_s, notice: 'You already have a variation entered'
    end
  end

  private

  def check_and_award_new_phenotypes(amount, achievement_string)
    if current_user.phenotype_creation_counter >= amount and UserAchievement.find_by_achievement_id_and_user_id(Achievement.find_by_award(achievement_string).id,current_user.id) == nil
      UserAchievement.create(achievement_id: Achievement.find_by_award(achievement_string).id, user_id: current_user.id)
    end
  end

  def check_and_award_additional_phenotypes(amount, achievement_string)
    if current_user.phenotype_count >= amount and UserAchievement.find_by_achievement_id_and_user_id(Achievement.find_by_award(achievement_string).id,current_user.id) == nil
      UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by_award(achievement_string).id)
    end
  end

end
