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

		respond_to do |format|
		  if @user.save
			flash[:notice] = "Account registered!"
			# create the new phenotype
			@phenotype = Phenotype.create(:user_id => @user.id)
			redirect_back_or_default root_path
		  else
			format.html { render :action => "new" }
			format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
		  end
		end
	end


	def index
		# showing all users
		@users = User.all

		respond_to do |format|
			format.html
			format.xml # just for the hell of it
		end
	end

	def show
		# showing a single user's page
		@user = current_user
		@title = @user.name + "'s page"

		respond_to do |format|
			format.html
		end
	end
end
