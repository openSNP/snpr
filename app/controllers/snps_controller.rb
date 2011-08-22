class SnpsController < ApplicationController
	def index
		@snps = Snp.paginate(:page => params[:page])

		respond_to do |format|
			format.html
			format.xml 
		end
	end
	
	def show
		@snp = Snp.find_by_id(params[:id])
		@users = User.find(:all, :conditions => { :user_snp => { :snps => { :id => @snp.id }}}, :joins => [ :user_snps => :snp])
    @total_genotypes = 0
    @snp.genotype_frequency.each do |key,value|
      @total_genotypes += value
    end
    
    @total_alleles = 0
    @snp.allele_frequency.each do |key,value|
      @total_alleles += value
    end
    
    Resque.enqueue(Plos,@snp)
    Resque.enqueue(Mendeley,@snp)
	Resque.enqueue(Snpedia,@snp)
		respond_to do |format|
			format.html
			format.xml
		end
	end

end
