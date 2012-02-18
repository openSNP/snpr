class NewsController < ApplicationController

	def index
		@title = "News"
		@new_genotypes = Genotype.all(:order => "created_at DESC", :limit => 20)
		@new_users = User.all(:order => "created_at DESC", :limit => 20)
		@new_phenotypes = Phenotype.all(:order => "created_at DESC", :limit => 20)
		@new_phenotype_comments = PhenotypeComment.all(:order => "created_at DESC", :limit => 20)
		@new_snp_comments = SnpComment.all(:order => "created_at DESC", :limit => 20)
		
		@newest_plos_paper = PlosPaper.all(:order => "created_at DESC", :limit => 20)
    @newest_mendeley_paper = MendeleyPaper.all(:order => "created_at DESC", :limit => 20)
    
    @newest_paper = @newest_mendeley_paper | @newest_plos_paper
    @newest_paper.sort! { |a,b| b.created_at <=> a.created_at }

		respond_to do |format|
			format.html
		end
	end
	
	def test
	  @title = "foo"
	  @new_genotypes = Genotype.all(:order => "created_at DESC", :limit => 20)
	  
	  respond_to do |format|
	    format.html
    end 
  end

  def paper_rss
    @newest_plos_paper = PlosPaper.all(:order => "created_at DESC", :limit => 20)
    @newest_mendeley_paper = MendeleyPaper.all(:order => "created_at DESC", :limit => 20)
    
    @newest_paper = @newest_mendeley_paper | @newest_plos_paper
    @newest_paper.sort! { |a,b| b.created_at <=> a.created_at }
    
      render :action => "paper_rss", :layout => false
  end

end
