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
            create_phenotypes
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


	def create_phenotypes
		Phenotype.create(:characteristic => "haircolor", :variation => "", :user_id => @user.id ).save
		Phenotype.create(:characteristic => "eyecolor", :variation => "", :user_id => @user.id ).save
		Phenotype.create(:characteristic => "skincolor", :variation => "", :user_id => @user.id ).save
		Phenotype.create(:characteristic => "bloodtype", :variation => "", :user_id => @user.id ).save
	end

end
