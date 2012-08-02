class SnpsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :find_snp, :except => [:index, :json]
    
	def index
		@snps = Snp.order(sort_column + " "+ sort_direction)
		@snps_paginate = @snps.paginate(:page => params[:page],:per_page => 10)
        @title = "Listing all SNPs"
		respond_to do |format|
			format.html
			format.xml 
		end
	end
	
	def show
		@snp = Snp.find_by_name(params[:id].downcase) || not_found
		@title = @snp.name
		@comments = SnpComment.where(:snp_id => @snp.id).all(:order => "created_at ASC")
		@users = User.find(:all, :conditions => { :user_snp => { :snps => { :id => @snp.id }}}, :joins => [ :user_snps => :snp])
		#@user_snps = UserSnps.where(:snp_name => @snp.name)
		
		@json_results = []
		
    @users.each do |u|
      @new_param = {}
      @new_param[:user_id] = u.id
      @new_param[:snp_name] = @snp.name
      @json_results << json_element(@new_param)
    end
		
		if current_user != nil
		  @user_snp = UserSnp.find_by_user_id_and_snp_name(current_user,@snp.name)
		  if @user_snp != nil
		    @local_genotype = @user_snp.local_genotype
	    else
	      @local_genotype = ""
      end
	  end
	  
		@total_genotypes = 0
		
		@snp.genotype_frequency.each do |key,value|
		  @total_genotypes += value
		end
    
		@total_alleles = 0
		@snp.allele_frequency.each do |key,value|
		  @total_alleles += value
		end
		
		Resque.enqueue(Plos,@snp.id)
		Resque.enqueue(Mendeley,@snp.id)
		Resque.enqueue(Snpedia,@snp.id)
		  
	    @snp_comment = SnpComment.new
			  
		respond_to do |format|
			format.html
			format.xml
			format.json { render :json => @json_results } 
		end
	end
	
	def json
	  if params[:user_id].index(",")
	    @user_ids = params[:user_id].split(",")
	    @results = []
	    @user_ids.each do |id|
	      @new_param = {}
	      @new_param[:user_id] = id
	      @new_param[:snp_name] = params[:snp_name].downcase
	      @results << json_element(@new_param)
      end
    elsif params[:user_id].index("-")
      @results = []
      @id_array = params[:user_id].split("-")
      @user_ids = (@id_array[0].to_i..@id_array[1].to_i).to_a
      @user_ids.each do |id|
        @new_param = {}
	      @new_param[:user_id] = id
	      @new_param[:snp_name] = params[:snp_name].downcase
	      @results << json_element(@new_param)
      end
	  else 
	    @results = json_element(params)
    end
    
    respond_to do |format|
      format.json { render :json => @results } 
    end
  end
  		
		private
		
		def sort_column
			Snp.column_names.include?(params[:sort]) ? params[:sort] : "ranking"
	  end
	  
	  def sort_direction
		%w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	  end

    def json_element(params)
      @result = {}
  	  begin
  	    @snp = Snp.find_by_name(params[:snp_name].downcase)
        @result["snp"] = {}
        @result["snp"]["name"] = @snp.name
        @result["snp"]["chromosome"] = @snp.chromosome
        @result["snp"]["position"] = @snp.position

        @user_snps = UserSnp.find_all_by_user_id_and_snp_name(params[:user_id],
                       params[:snp_name].downcase)
        @user = User.find_by_id(params[:user_id])
        @genotypes_array = []

        @user_snps.each do |us|
          @genotype_hash = {}
          @genotype_hash["genotype_id"] = us.genotype_id
          @genotype_hash["local_genotype"] = us.local_genotype
          @genotypes_array << @genotype_hash
        end

        @result["user"] = {}
        @result["user"]["name"] = @user.name
        @result["user"]["id"] = @user.id
        @result["user"]["genotypes"] = @genotypes_array
      rescue
        @result = {}
        @result["error"] = "Sorry, we couldn't find any information for SNP "+params[:snp_name].to_s+" and user "+params[:user_id].to_s
      end
      return @result
    end

    def find_snp
      @snp = Snp.find(params[:id].downcase) || not_found

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      if request.path != snp_path(@snp)
        if request.path.index(".json") == nil
          return redirect_to @snp, :status => :moved_permanently
        end
      end
    end

	end
