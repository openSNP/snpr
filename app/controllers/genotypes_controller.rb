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
		@genotype.filetype=params[:genotype][:filetype]
    @genotype.originalfilename=params[:genotype][:filename].original_filename if params[:genotype][:filename]

		respond_to do |format|
		  if @user.save

			format.html { redirect_to(@user, :notice => 'User was successfully created.') }
			format.xml { render :xml => @user, :status => :created, :location => @user }
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
   @genotype.user=@current_user
   @genotype.uploadtime=Time.new
   @genotype.filetype=params[:genotype][:filetype]
   @genotype.originalfilename=params[:genotype][:filename].original_filename if params[:genotype][:filename]
   if @genotype.save
     @genotype.move_file
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
