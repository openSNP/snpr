# frozen_string_literal: true
class PhenotypeSetsController < ApplicationController
  before_action :require_user

  def enter_userphenotypes
    puts params
    @phenotypeset = PhenotypeSet.find_by_id(params[:id])
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
    @user_phenotypes = params[:user_phenotypes]['user_phenotypes']
    puts @user_phenotypes
    @user_phenotypes.each do |up|
      if not up['variation'].empty?
        @phenotype = Phenotype.find_by_id(up['phenotype'].to_s)
        @user_phenotype = UserPhenotype.find_by_user_id_and_phenotype_id(current_user.id,up['phenotype'].to_s)
        if @user_phenotype == nil
          @user_phenotype = current_user.user_phenotypes.build
          @user_phenotype.phenotype_id = up['phenotype'].to_s
        end
        @user_phenotype.variation = up['variation']
        @user_phenotype.save
        @phenotype.save
      end
    end
  end


end
