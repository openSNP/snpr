class PasswordResetsController < ApplicationController

	before_filter :load_user_using_perishable_token, :only => [:edit, :update]
	before_filter :require_no_user

	def new
		@title = 'password reset'
		render
	end

	def edit
		@title = 'editing your password'
		render
	end

	def update
		@user.password = params[:user][:password]
		@user.password_confirmation = params[:user][:password_confirmation]
		if @user.save
			flash[:notice] = 'Password successfully updated'
			redirect_to '/'
		else
      render :action => :edit
		end
	end

	def create
		@user = User.find_by_email(params[:email])
		if @user
			@user.deliver_password_reset_instructions!
			flash[:notice] = 'Instructions to reset your password have been mailed to you. Please check your email'
			redirect_to root_url
		else
			flash[:notice] = 'No user was found with that email adress'
			render :action => :new
		end
	end

	private

	def load_user_using_perishable_token
		@user = User.find_using_perishable_token(params[:id])
		unless @user
			flash[:notice] = 'We\'re sorry, but we couldn\'t locate your account. Try copy and pasting the url from the mail you received from us or restarting the password reset process'
			redirect_to root_url
		end
	end
end
