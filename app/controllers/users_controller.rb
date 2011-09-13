class UsersController < ApplicationController
  
  helper_method :sort_column, :sort_direction

	def new
		@user = User.new
		@title = "Sign up"

		respond_to do |format|
			format.html
			format.xml { render :xml => @user }
		end
	end

	def create
		@user = User.new(params[:user])

		  if not params[:read]
			  flash[:warning] = "You must tick the box to proceed!"
		  end

		  if params[:read] and @user.save
			homepage = @user.homepages.build(:user_id => current_user.id)
			flash[:notice] = "Account registered!"
			redirect_to @user
		  else
			respond_to do |format|
				format.html { render :action => "new" }
				format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
		  	end
		  end
	end


	def index
		# showing all users
		@users = User.paginate(:page => params[:page])
		# paginate because at some point, we might have more than 30 users!
		# a man can dream...
		@title = "Listing all users"
		respond_to do |format|
			format.html
			format.xml 
		end
	end

	def show
		# showing a single user's page
		@user = User.find_by_id(params[:id])
		@title = @user.name + "'s page"
		@first_name = @user.name.split()[0]
		@user_phenotypes = @user.user_phenotypes
		@temp_snps = @user.snps.order(sort_column + " "+ sort_direction)
		@snps = @temp_snps.paginate(:page => params[:page])
		@received_messages = @user.messages.where(:sent => false).all(:order => "created_at DESC")
		@sent_messages = @user.messages.where(:sent => true).all(:order => "created_at DESC")
		@phenotype_comments = PhenotypeComment.where(:user_id => @user.id).paginate(:page => params[:page])
		@snp_comments = SnpComment.where(:user_id => @user.id).paginate(:page => params[:page])

		respond_to do |format|
			format.html
		end
	end

	def edit
	   @user = User.find(params[:id])

       respond_to do |format|
		   format.html
		   format.xml
	   end
	end

	def update
		@user = User.find(params[:id])
		
		if @user.update_attributes(params[:user])
			
			params["user"]["user_phenotypes_attributes"].each do |p|
			  @phenotype = Phenotype.find(UserPhenotype.find(p[1]["id"]).phenotype_id)
			  if @phenotype.known_phenotypes.include?(p[1]["variation"]) == false
			    @phenotype.known_phenotypes << p[1]["variation"]
			    @phenotype.number_of_users = UserPhenotype.find_all_by_phenotype_id(@phenotype.id).length
			    @phenotype.save
		    end
		  end
		  
			flash[:notice] =  "Successfully updated"
			redirect_to :controller => "users", :id => @user.id, :action => "edit"
		else
			render :action => 'edit' 
		end
	end

	def destroy
		@user = User.find(params[:id])
		# delete the genotype
		@genotype = @user.genotypes[0]
		if @genotype
			Resque.enqueue(Deletegenotype, @genotype)
			@genotype.delete
		end
		@user.user_phenotypes.each do |up|
			@phenotype = Phenotype.find_by_id(up.phenotype_id)
			if @phenotype.user_phenotypes.length == 1
				Phenotype.delete(@phenotype)
			end
			UserPhenotype.delete(up)
		end
		flash[:notice] = "Thank you for using SNPr. Goodbye!"
        User.delete(@user)
		redirect_to root_url
	end
	
	private
	
	def sort_column
		Snp.column_names.include?(params[:sort]) ? params[:sort] : "ranking"
  end
  
  def sort_direction
	%w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
	
end
