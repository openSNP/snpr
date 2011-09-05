class SearchResultsController < ApplicationController

  def search
	  @phenotypes = Phenotype.solr_search do |p|
		  p.keywords params[:search]
	  end
	  @users  = User.solr_search do |p|
		  p.keywords params[:search]
	  end          
	  @user_phenotypes = UserPhenotype.solr_search do |p|
		  p.keywords params[:search]
	  end          
  end
end
