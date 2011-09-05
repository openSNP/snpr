class SearchResultsController < ApplicationController

  def search
	  # butt-ugly
	  
	  @snps = Snp.solr_search do |p|
		  p.keywords params[:search]
	  end

	  @phenotypes = Phenotype.solr_search do |p|
		  p.keywords params[:search]
	  end
	  @users  = User.solr_search do |p|
		  p.keywords params[:search]
	  end          
	  @user_phenotypes = UserPhenotype.solr_search do |p|
		  p.keywords params[:search]
	  end          

	  @snp_comments  = SnpComment.solr_search do |p|
		  p.keywords params[:search]
	  end               
	  @phenotype_comments  = PhenotypeComment.solr_search do |p|
		  p.keywords params[:search]
	  end               
	  @mendeley_papers  = MendeleyPaper.solr_search do |p|
		  p.keywords params[:search]
	  end               
	  @plos_papers  = PlosPaper.solr_search do |p|
		  p.keywords params[:search]
	  end               
	  @snpedia_papers   = SnpediaPaper.solr_search do |p|
		  p.keywords params[:search]
	  end               
  end
end
