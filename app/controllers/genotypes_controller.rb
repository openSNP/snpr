class GenotypesController < ApplicationController
  
  def new
		@genotype = Genotype.new
		# current user is always stored in the method 'current_user',
		# not in the variable '@current_user'
		@genotype.user = current_user
    	@genotype.uploadtime=Time.new
		@title = "Add Genotype-File"

		respond_to do |format|
			format.html
			format.xml { render :xml => @user }
		end
	end
	
	def create
		@genotype = Genotype.new()
		@genotype.uploadtime = Time.new 
		@genotype.user_id = current_user.id
		@genotype.filetype=params[:genotype][:filetype]
    	@genotype.originalfilename=params[:genotype][:filename].original_filename if params[:genotype][:filename].original_filename
    	@genotype.data=params[:genotype][:filename].read if params[:genotype][:filename]

		respond_to do |format|
		  if @genotype.save
            current_user.toggle!(:has_sequence)
            @genotype.move_file
			format.html { redirect_to(current_user, :notice => 'Genotype was successfully uploaded') }
			format.xml { render :xml => current_user, :status => :created, :location => @user }
		  else
			format.html { render :action => "new" }
			format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
		  end
		end
	end

	def show
		@genotype = Genotype.find(params[:id])
		@user = User.find_by_id(@genotype.user_id)
	
		@title = "Genotypes"
		respond_to do |format|
			format.html
			format.xml
		end
	end
	
	def do_upload_genotype
		@genotype=Genotype.new()
		@genotype.user=current_user
		@genotype.uploadtime=Time.new
		@genotype.filetype=params[:genotype][:filetype]
		@genotype.originalfilename=params[:genotype][:filename].original_filename if params[:genotype][:filename]
   
		if @genotype.save
     		@genotype.move_file
     	  genotype_file = File.open(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename, "r")
     	  new_snps = genotype_file.readlines
     	  new_snps.each do |single_snp|
     	    if single_snp[0] != "#"
       	    snp_array = single_snp.split("\t")
       	    @snp = Snp.new()
       	    @snp.genotype = @genotype
       	    @snp.name = snp_array[0]
       	    @snp.chromosome = snp_array[1]
       	    @snp.position = snp_array[2]
       	    @snp.local_genotype = snp_array[3]
       	    @snp.save
     	    end
   	    end
     	    
			flash[:notice]="File upload successful!"
			redirect_to :action => :info_page
		else
			render :action=>"upload_genotype"
		end

		respond_to do |format|
			format.html
		end
  end

end
