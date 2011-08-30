class NewsController < ApplicationController

	def index
		@title = "News"
		@new_genotypes = Genotype.all(:order => "created_at DESC", :limit => 20)
		@new_users = User.all(:order => "created_at DESC", :limit => 20)
		@new_phenotypes = UserPhenotype.all(:order => "created_at DESC", :limit => 20)

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
end
