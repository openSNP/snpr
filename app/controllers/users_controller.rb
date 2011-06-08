class UsersController < ApplicationController
    # let non-authenticated users only see show, new, create
	before_filter :authenticate, :except => [:index, :show, :new, :create]
	# let only the corret user use edit and update
	before_filter :correct_user, :only => [:edit, :update]

	def new
		@user = User.new
		@title = "Sign up"
	end

	def create
		@user = User.new(params[:id])
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to SNPR!"
			redirect_to @user
		else
			@title = "Sign up"
			render 'new'
		end
	end


	def index
		# showing all users
		@users = User.find(:all)

		respond_to do |format|
			format.html
			format.xml # just for the hell of it
		end
	end

	def show
		# showing a single user's page
		@user = User.find(params[:id])

		respond_to do |format|
			format.html
		end
	end

	private

	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_path) unless current_user?(@user)
	end

	def admin_user
		redirect_to(root_path) unless current_user.admin?
	end

end
