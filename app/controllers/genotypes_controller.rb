class GenotypesController < ApplicationController

  before_filter :require_user, except: [ :show, :feed,:index,:dump_download ]
  helper_method :sort_column, :sort_direction

  def index
    @title = "Listing all genotypings"
    @genotypes = Genotype.order("#{sort_column} #{sort_direction}")
    @genotypes_paginate = @genotypes.paginate(page: params[:page],per_page: 20)
  end

  def new
    @genotype = Genotype.new
    @title = "Add Genotype-File"
  end

  def create
    @genotype = Genotype.create(genotype_params)
    @genotype.user = current_user
    if @genotype.valid? && @genotype.save
      # award for genotyping-upload
      @award = Achievement.find_by_award("Published genotyping")
      user_achievement_attrs = { achievement_id: @award.id,
                                 user_id: current_user.id }
      if UserAchievement.where(user_achievement_attrs).count.zero?
        UserAchievement.create(user_achievement_attrs)
        flash[:achievement] = "Congratulations! You've unlocked an achievement:" +
          " <a href=\"#{url_for(@award)}\">#{@award.award}</a>"
      end

      if current_user.has_sequence == false
        current_user.toggle!(:has_sequence)
      end
      redirect_to(current_user, notice: 'Genotype was successfully uploaded! Parsing and annotating might take a couple of <strike>hours</strike> days.')
    else
      render :action => "new"
    end
  end

  def show
    @genotype = Genotype.find(params[:id])
    @user = @genotype.user
    @title = "Genotypes"
  end

  def feed
    # for rss-feeds
    @genotypes = Genotype.order('created_at DESC').limit(20)
    render :action => "rss", :layout => false
  end

  def destroy
    @user = current_user
    @genotype = Genotype.find_by_id(params[:id])
    if @genotype.destroy
      flash[:notice] = "Genotyping was successfully deleted."
      if @user.genotypes.count == 0
        # update user-attributes
        @user.update_attributes(has_sequence: false, sequence_link: nil)

        # delete Uploaded Genotyping-achievement
        @achievement_id = Achievement.find_by_award("Published genotyping").id
        @to_delete = UserAchievement.find_by_achievement_id_and_user_id(@achievement_id, @user.id)
        UserAchievement.destroy(@to_delete)
      end
      redirect_to current_user
    end
  end

  private 

  def sort_column
    Genotype.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def genotype_params
    params.require(:genotype).permit(:genotype, :filetype)
  end

end
