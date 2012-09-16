class PhenotypeSetsController < ApplicationController
  before_filter :require_user
  
  def enter_userphenotypes
    puts params
    @phenotypes = PhenotypeSet.find_by_id(params[:id]).phenotypes
    @user_phenotypes = []
    @phenotypes.each do |p|
      @up = current_user.user_phenotypes.build
      @up.phenotype_id = p.id
      @user_phenotypes << @up
    end
    @user = current_user
  end
  
  def save_user_phenotypes
    @user = current_user

    @user_phenotypes = UserPhenotype.create(params[:user_phenotypes])
    puts params[:user_phenotypes]
  end
  
  
end