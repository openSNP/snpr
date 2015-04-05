class PicturePhenotypesController < ApplicationController
  before_filter :require_user, only: [:new, :create,]
  helper_method :sort_column, :sort_direction

  def index
    @title = 'Listing all phenotypes'
    @phenotypes = PicturePhenotype.order(sort_column + ' ' + sort_direction)
    @phenotypes_paginate = @phenotypes.paginate(page: params[:page], per_page: 10)
    # @phenotypes_json = []
    # @phenotypes.each do |p|
    #  @phenotype = {}
    #  @phenotype["id"] = p.id
    #  @phenotype["characteristic"] = p.characteristic
    #  @phenotype["known_variations"] = p.known_phenotypes
    #  @phenotype["number_of_users"] = p.user_phenotypes.length
    #  @phenotypes_json << @phenotype
    # end
    respond_to do |format|
      format.html
      format.xml
      # format.json {render :json => @phenotypes_json}
    end
  end

  def new
    @phenotype = PicturePhenotype.new
    @user_phenotype = UserPicturePhenotype.new
    @title = 'Create a new picture phenotype'

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def create
    unless @phenotype = PicturePhenotype.find_by_characteristic(params[:picture_phenotype][:characteristic])
      puts params[:picture_phenotype]
      @phenotype = PicturePhenotype.create(picture_phenotype_params)

      # award: created one (or more) phenotypes
      current_user.update_attributes(phenotype_creation_counter: (current_user.phenotype_creation_counter + 1))

      check_and_award_new_phenotypes(1, 'Created a new phenotype')
      check_and_award_new_phenotypes(5, 'Created 5 new phenotypes')
      check_and_award_new_phenotypes(10, 'Created 10 new phenotypes')
    end

    if params[:picture_phenotype][:characteristic] == ''
      flash[:warning] = 'Phenotype characteristic may not be empty'
      redirect_to action: 'new'
    else

      @phenotype.save
      @phenotype = PicturePhenotype.find_by_characteristic(params[:picture_phenotype][:characteristic])
      # Sidekiq::Client.enqueue(Mailnewphenotype, @phenotype.id,current_user.id)

      if UserPicturePhenotype.find_by_picture_phenotype_id_and_user_id(@phenotype.id, current_user.id).nil?

        @user_phenotype = current_user.user_picture_phenotypes.new(
          phenotype_picture: params[:user_picture_phenotype][:phenotype_picture])
        @user_phenotype.picture_phenotype = @phenotype

        if @user_phenotype.save
          @phenotype.number_of_users = UserPicturePhenotype.find_all_by_picture_phenotype_id(@phenotype.id).length
          @phenotype.save
          flash[:notice] = 'Picture Phenotype sucessfully saved.'

          # check for additional phenotype awards
          current_user.update_attributes(phenotype_additional_counter: current_user.user_phenotypes.count)

          check_and_award_additional_phenotypes(1, 'Entered first phenotype')
          check_and_award_additional_phenotypes(5, 'Entered 5 additional phenotypes')
          check_and_award_additional_phenotypes(10, 'Entered 10 additional phenotypes')
          check_and_award_additional_phenotypes(20, 'Entered 20 additional phenotypes')
          check_and_award_additional_phenotypes(50, 'Entered 50 additional phenotypes')
          check_and_award_additional_phenotypes(100, 'Entered 100 additional phenotypes')

          # Sidekiq::Client.enqueue(Recommendvariations)
          # Sidekiq::Client.enqueue(Recommendphenotypes)

          redirect_to current_user
        else
          flash[:warning] = 'Something went wrong in creating the phenotype'
          redirect_to action: 'new'
        end
      else
        flash[:warning] = 'You have already entered your variation at this phenotype'
        redirect_to action: 'new'
      end
    end
  end

  def show
    # @phenotypes = Phenotype.where(:user_id => current_user.id).all
    # @title = "Phenotypes"
    @phenotype = PicturePhenotype.find(params[:id]) || not_found
    @comments = PicturePhenotypeComment
      .where(picture_phenotype_id: params[:id])
      .order(:created_at)
    @phenotype_comment = PicturePhenotypeComment.new
    if current_user && UserPicturePhenotype.find_by_user_id_and_picture_phenotype_id(current_user.id, @phenotype.id)
      @user_phenotype = UserPicturePhenotype.find_by_user_id_and_picture_phenotype_id(current_user.id, @phenotype.id)
    else
      @user_phenotype = UserPicturePhenotype.new
    end

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def feed
    @phenotype = PicturePhenotype.find(params[:id])
    @user_phenotypes = @phenotype.user_picture_phenotypes
    @genotypes = []
    @user_phenotypes.each do |up|
      unless up.user.genotypes[0].nil?
        @genotypes << up.user.genotypes[0]
      end
    end

    @genotypes.sort! { |b, a| a.created_at <=> b.created_at }

    render action: 'rss', layout: false
  end

  private

  def sort_column
    PicturePhenotype.column_names.include?(params[:sort]) ? params[:sort] : 'number_of_users'
  end

  private

  def sort_column
    PicturePhenotype.column_names.include?(params[:sort]) ? params[:sort] : 'number_of_users'
  end

  def sort_direction
    %w(desc asc).include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def check_and_award_new_phenotypes(amount, achievement_string)
    @achievement = Achievement.find_by_award(achievement_string)
    if current_user.phenotype_creation_counter >= amount && UserAchievement.find_by_achievement_id_and_user_id(@achievement.id, current_user.id).nil?

      UserAchievement.create(achievement_id: @achievement.id, user_id: current_user.id)
      flash[:achievement] = %(Congratulations! You've unlocked an achievement: <a href="#{url_for(@achievement)}">#{@achievement.award}</a>).html_safe
    end
  end

  def check_and_award_additional_phenotypes(amount, achievement_string)
    @achievement = Achievement.find_by_award(achievement_string)
    if current_user.phenotype_additional_counter >= amount && UserAchievement.find_by_achievement_id_and_user_id(@achievement.id, current_user.id).nil?
      UserAchievement.create(user_id: current_user.id, achievement_id: @achievement.id)
      flash[:achievement] = %(Congratulations! You've unlocked an achievement: <a href="#{url_for(@achievement)}">#{@achievement.award}</a>).html_safe
    end
  end

  def picture_phenotype_params
    params.require(:picture_phenotype).permit(:characteristic, :description)
  end
end
