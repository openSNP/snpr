# frozen_string_literal: true
class GenotypesController < ApplicationController

  before_filter :require_user, except: [ :show, :feed,:index,:dump_download ]
  helper_method :sort_column, :sort_direction

  def index
    @title = "Listing all genotypings"
    @genotypes =
      Genotype
      .includes(:user)
      .order("#{sort_column} #{sort_direction}")
    @genotypes_paginate = @genotypes.paginate(page: params[:page], per_page: 20)
  end

  def new
    @genotype = Genotype.new
    @title = 'Add Genotype-File'
  end

  def create
    @genotype = Genotype.new(genotype_params)
    @genotype.user = current_user
    @genotype.parse_status = 'queued'
    if @genotype.valid? && @genotype.save
      Preparsing.perform_async(@genotype.id)
      # award for genotyping-upload
      @award = Achievement.find_by_award('Published genotyping')
      user_achievement_attrs = { achievement_id: @award.id,
                                 user_id: current_user.id }
      if UserAchievement.where(user_achievement_attrs).count.zero?
        UserAchievement.create(user_achievement_attrs)
        flash[:achievement] = 'Congratulations! You\'ve unlocked an achievement:' +
          " <a href=\"#{url_for(@award)}\">#{@award.award}</a>"
      end

      if current_user.has_sequence == false
        current_user.toggle!(:has_sequence)
      end
      redirect_to(current_user, notice: 'Genotype was successfully uploaded! Parsing and annotating might take a couple of <strike>hours</strike> days.')
    else
      render action: 'new'
    end
  end

  def show
    @genotype = Genotype.find(params[:id])
    @user = @genotype.user
    @title = 'Genotypes'
  end

  def feed
    # for rss-feeds
    @genotypes = Genotype.order('created_at DESC').limit(20)
    render action: 'rss', layout: false
  end

  def destroy
    genotype = current_user.genotypes.find(params[:id])
    DeleteGenotype.perform_async(genotype_id: genotype.id)
    flash[:notice] = 'Your Genotyping will be deleted. This may take a few minutes...'
    redirect_to current_user
  end

  private

  def sort_column
    Genotype.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def genotype_params
    params.require(:genotype).permit(:genotype, :filetype)
  end

end
