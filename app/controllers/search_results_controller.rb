class SearchResultsController < ApplicationController

  def search_type(type)
	  return type.solr_search { |p| p.keywords params[:search] }
  end

  def search
	  @title = "Search results"
	  @snps = search_type Snp
	  @phenotypes = search_type Phenotype
	  @users  = search_type User
	  @user_phenotypes = search_type UserPhenotype
	  @snp_comments  = search_type SnpComment
	  @phenotype_comments  = search_type PhenotypeComment
	  @mendeley_papers  = search_type MendeleyPaper
	  @plos_papers  = search_type PlosPaper
	  @snpedia_papers   = search_type SnpediaPaper
  end
 

end
