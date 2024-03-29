# frozen_string_literal: true
class PhenotypesController < ApplicationController
  before_filter :require_user, only: %i(new create get_genotypes recommend_phenotype)
  helper_method :sort_column, :sort_direction

  def index
    @title = 'Listing all phenotypes'
    @phenotypes = Phenotype
      .with_number_of_users
      .order("#{sort_column} #{sort_direction}")
      .includes(:user_phenotypes)

    @phenotypes_paginate = @phenotypes.paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html
      format.xml
      format.json do
        phenotypes_json =
          @phenotypes.find_each.map do |p|
            {
              id: p.id,
              characteristic: p.characteristic,
              known_variations: p.known_phenotypes,
              number_of_users: p.number_of_users
            }
          end
        render json: phenotypes_json
      end
    end
  end

  def new
    @phenotype = Phenotype.new
    @user_phenotype = UserPhenotype.new
    @title = 'Create a new phenotype'

    # Make list of phenotypes for autocomplete
    @phenotype_list = Phenotype.pluck(:characteristic).to_json

    # Make list of phenotypes for autocomplete
    @phenotype_list = Phenotype.pluck(:characteristic).to_json
  end

  def create
    @phenotype = Phenotype.find_or_initialize_by(phenotype_params.slice(:characteristic)) do |p|
      p.assign_attributes(phenotype_params)
    end
    new_phenotype = @phenotype.new_record?
    @phenotype.user_phenotypes_attributes = user_phenotype_params

    if @phenotype.save
      if new_phenotype
        current_user.phenotype_creation_counter += 1
        current_user.save!

        check_and_award_new_phenotypes(1, 'Created a new phenotype')
        check_and_award_new_phenotypes(5, 'Created 5 new phenotypes')
        check_and_award_new_phenotypes(10, 'Created 10 new phenotypes')

        Mailnewphenotype.perform_async(@phenotype.id, current_user.id)
      end

      # check for additional phenotype awards
      check_and_award_additional_phenotypes(1, 'Entered first phenotype')
      check_and_award_additional_phenotypes(5, 'Entered 5 additional phenotypes')
      check_and_award_additional_phenotypes(10, 'Entered 10 additional phenotypes')
      check_and_award_additional_phenotypes(20, 'Entered 20 additional phenotypes')
      check_and_award_additional_phenotypes(50, 'Entered 50 additional phenotypes')
      check_and_award_additional_phenotypes(100, 'Entered 100 additional phenotypes')

      flash[:notice] = 'Phenotype successfully created.'

      redirect_to current_user
    else
      render :new
    end
  end

  def show
    @phenotype = Phenotype.find(params[:id])
    @comments = @phenotype
                .phenotype_comments
                .order('created_at ASC')
    @phenotype_comment = PhenotypeComment.new
    @user_phenotype = UserPhenotype.new
    @similar_phenotypes =
      PhenotypeRecommender.new.recommendations_for(@phenotype.id, 6)
  end

  def recommend_phenotype
    @phenotype = Phenotype.find(params[:id])

    # get up to three similar phenotypes regardless of variation
    @similar_phenotypes =
      PhenotypeRecommender.new.recommendations_for(@phenotype.id, 3)

    # get up to three similar combinations of phenotype and variation
    @user_phenotype = @phenotype
                      .user_phenotypes
                      .find_by(user_id: current_user.id)
    @similar_variations =
      VariationRecommender.new.recommendations_for(@user_phenotype, 3)

    if @similar_phenotypes.none? && @similar_variations.none?
      redirect_to action: 'index'
    end
  end

  def feed
    @phenotype = Phenotype.find(params[:id])
    @user_phenotypes = @phenotype.user_phenotypes
    @genotypes = []
    @user_phenotypes.each do |up|
      if up.user.genotypes[0] != nil
        @genotypes << up.user.genotypes[0]
      end
    end

    @genotypes.sort!{ |b,a| a.created_at <=> b.created_at }

    render action: 'rss', layout: false
  end

  def get_genotypes
    ZipGenotypingFiles.perform_async(
      params[:id],
      params[:variation],
      current_user.email
    )
    @phenotype = Phenotype.find(params[:id])
    @variation = params[:variation]
  end

  def json_variation
    @result = {}
    begin
      @phenotype = Phenotype.find_by(id: params[:phenotype_id])
      @result['id'] = @phenotype.id
      @result['characteristic'] = @phenotype.characteristic
      @result['description'] = @phenotype.description
      @result['known_variations'] = @phenotype.known_phenotypes
      @result['users'] = []
      @phenotype.user_phenotypes.each do |up|
        @user_phenotype = { 'user_id' => up.user_id,
                            'variation' => up.variation }
        @result['users'] << @user_phenotype
      end
    rescue
      @result['error'] = 'Sorry, this phenotype doesn\'t exist'
    end

    render json: @result
  end

  def json
    if params[:user_id].index(',')
      @user_ids = params[:user_id].split(',')
      @results = []
      @user_ids.each do |id|
        @new_param = {}
        @new_param[:user_id] = id
        @results << json_element(@new_param)
      end

    elsif params[:user_id].index('-')
      @results = []
      @id_array = params[:user_id].split('-')
      @user_ids = (@id_array[0].to_i..@id_array[1].to_i).to_a
      @user_ids.each do |id|
        @new_param = {}
        @new_param[:user_id] = id
        @results << json_element(@new_param)
      end

    else
      @results = json_element(params)
    end

    render json: @results
  end

  def json_element(params)
    begin
      @user = User.find_by(id: params[:user_id])
      @result = {}
      @user_phenotypes = UserPhenotype.where(user_id: @user.id)

      @result['user'] = {}
      @result['user']['name'] = @user.name
      @result['user']['id'] = @user.id

      @phenotype_hash = {}

      @user_phenotypes.each do |up|
        @phenotype_hash[up.phenotype.characteristic] = {}
        @phenotype_hash[up.phenotype.characteristic]['phenotype_id'] = up.phenotype.id
        @phenotype_hash[up.phenotype.characteristic]['variation'] = up.variation
      end

      @result['phenotypes'] = @phenotype_hash
    rescue
      @result = {}
      @result['error'] = 'Sorry, we couldn\'t find any information for this user'
    end
    return @result
  end

  private

  def sort_column
    Phenotype.column_names.include?(params[:sort]) ? params[:sort] : 'number_of_users'
  end

  private

  def sort_column
    Phenotype.column_names.include?(params[:sort]) ? params[:sort] : 'number_of_users'
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def check_and_award_new_phenotypes(amount, achievement_string)
    @achievement = Achievement.find_by_award(achievement_string)
    if current_user.phenotype_creation_counter >= amount and UserAchievement.find_by_achievement_id_and_user_id(@achievement.id,current_user.id) == nil

      UserAchievement.create(achievement_id: @achievement.id, user_id: current_user.id)
      flash[:achievement] = %(Congratulations! You've unlocked an achievement: <a href="#{url_for(@achievement)}">#{@achievement.award}</a>).html_safe
    end
  end

  def check_and_award_additional_phenotypes(amount, achievement_string)
    @achievement = Achievement.find_by_award(achievement_string)
    if current_user.phenotype_count >= amount and UserAchievement.find_by_achievement_id_and_user_id(@achievement.id,current_user.id) == nil
      UserAchievement.create(user_id: current_user.id, achievement_id: @achievement.id)
      flash[:achievement] = %(Congratulations! You've unlocked an achievement: <a href="#{url_for(@achievement)}">#{@achievement.award}</a>).html_safe
    end
  end

  def phenotype_params
    params.require(:phenotype).permit(:description, :characteristic)
  end

  def user_phenotype_params
    params
      .require(:phenotype)
      .permit(user_phenotypes_attributes: [[:variation]])
      .require(:user_phenotypes_attributes)
      .values
      .map { |user_phenotype| user_phenotype.merge(user_id: current_user.id) }
  end
end
