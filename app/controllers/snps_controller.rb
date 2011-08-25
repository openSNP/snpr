class SnpsController < ApplicationController
  helper_method :sort_column, :sort_direction
	def index
		@snps = Snp.order(sort_column + " "+ sort_direction)
		@snps_paginate = @snps.paginate(:page => params[:page],:per_page => 10)

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
	  
	  @snp_comment = SnpComment.new
	  	  
		respond_to do |format|
			format.html
			format.xml
		end
	end
	
	private
	
	def sort_column
		Snp.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
