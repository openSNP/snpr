class UsersController < ApplicationController

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
		# split the user's name if there are more than two strings
		# for possible reference by first name
		@first_name = @user.name.split()[0]
		@phenotypes = @user.user_phenotypes
		@snps = @user.snps.paginate(:page => params[:page])
		@received_messages = @user.messages.where(:sent => false).all(:order => "created_at DESC")
		@sent_messages = @user.messages.where(:sent => true).all(:order => "created_at DESC")

		respond_to do |format|
			format.html
		end
	end

	def edit
	   @user = User.find(params[:id])
	   @phenotypes = @user.user_phenotypes

       respond_to do |format|
		   format.html
		   format.xml
	   end
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(params[:user])
			redirect_to @user, :notice => "Successfully updated."
		else
			render :action => 'edit' 
		end
	end
end
