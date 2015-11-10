class UsersController < ApplicationController

  helper_method :sort_column, :sort_direction
  before_filter :require_owner, only: [ :update, :destroy, :edit, :changepassword ]
  before_filter :require_no_user, :only => [:new, :create]

  def new
    @user = User.new
    @title = "Sign up"

    respond_to do |format|
      format.html
      format.xml { render :xml => @user }
    end
  end

  def create
    @user = User.new(user_params)

    if not params[:read]
      flash[:warning] = "You must tick the box to proceed!"
    end

    if params[:read] && verify_recaptcha(model: @user) && @user.save
      flash[:notice] = "Account registered!"
      UserMailer.welcome_user(@user).deliver_later
      redirect_to @user
    else
      render :new
    end
  end


  def index
    # showing all users
    # TODO: Refactor this. - Helge
    @users = User.order(sort_column + " " + sort_direction)
    @users_paginate = @users.paginate(:page => params[:page], :per_page => 10)
    @title = "Listing all users"

    if request.format.json?
      @result = []
      begin
        @users = User.all
        @users.each do |u|
          @user = {}
          @user["name"] = u.name
          @user["id"] = u.id
          @user["genotypes"] = []
          Genotype.where(user_id: u.id).each do |g|
            @genotype = {}
            @genotype["id"] = g.id
            @genotype["filetype"] = g.filetype
            @genotype["download_url"] = 'http://opensnp.org/data/' + g.fs_filename
            @user["genotypes"] << @genotype
          end
          @result << @user
        end

      rescue
        @result = {}
        @result["error"] = "Sorry, we couldn't find any users"
      end
    end

    respond_to do |format|
      format.html
      format.json { render :json => @result }
    end
  end

  def show
    # showing a single user's page
    @user = User.find_by_id(params[:id]) || not_found
    @title = @user.name + "'s page"
    @first_name = @user.name.split.first
    @user_phenotypes = @user.user_phenotypes
    #@snps = @user.snps.order("#{sort_column} #{sort_direction}").paginate(:page => params[:page])
    @received_messages = @user.messages.where(sent: false).order('created_at DESC')
    @sent_messages = @user.messages.where(:sent => true).order('created_at DESC')
    @phenotype_comments = PhenotypeComment.where(:user_id => @user.id).paginate(:page => params[:page])
    @snp_comments = SnpComment.where(:user_id => @user.id)

    # get phenotypes that current_user did not enter yet
    @unentered_phenotypes = Phenotype.all - @user.phenotypes
    @unentered_phenotypes = @unentered_phenotypes.shuffle
    @unentered_phenotypes = @unentered_phenotypes[0..20]

    #find all snp-comment-replies that this user got
    @user_snp_comment_ids = []
    @snp_comments.each do |sc| @user_snp_comment_ids << sc.id end
    @snp_comment_replies = []
    @user_snp_comment_ids.each do |ui| 
      @replies_for_snp = SnpComment.where(reply_to_id: ui)
      @replies_for_snp.each do |rs|
        @snp_comment_replies << rs
      end
    end  
    @snp_comment_replies.sort! { |b,a| a.created_at <=> b.created_at }
    @paginated_snp_replies = @snp_comment_replies

    #find all phenotype-comment-replies that this user got
    @user_phenotype_comment_ids = []
    @phenotype_comments.each do |pc| @user_phenotype_comment_ids << pc.id end
    @phenotype_comment_replies = []
    @user_phenotype_comment_ids.each do |pi|
      @replies_for_phenotype = PhenotypeComment.where(reply_to_id: pi).all
      @replies_for_phenotype.each do |rp|
        @phenotype_comment_replies << rp
      end
    end
    @phenotype_comment_replies.sort! { |b,a| a.created_at <=> b.created_at }
    @paginated_phenotype_replies = @phenotype_comment_replies

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

  def changepassword
    @user = User.find_by_id(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if params[:user][:user_phenotypes_attributes].present?
      params[:user][:user_phenotypes_attributes].each do |p|  
        @phenotype = UserPhenotype.find(p[1]["id"]).phenotype
        @old_variation = UserPhenotype.find_by_id(p[1]["id"]).variation
        # TODO: known_phenotypes compare different now
        if @phenotype.known_phenotypes.include?(p[1]["variation"]) == false
          @phenotype.number_of_users = UserPhenotype.where(phenotype_id: @phenotype.id).count
          @phenotype.save
        end
      end
    end

    if params[:user][:description].present?
      params[:user][:description] = Sanitize.clean(params[:user][:description], Sanitize::Config::RESTRICTED)
    end

    if @user.update_attributes(user_params)
      @empty_websites = Homepage.where(user_id: current_user.id, url: '')
      @empty_websites.each do |ew| ew.delete end

      Sidekiq::Client.enqueue(Recommendvariations)
      Sidekiq::Client.enqueue(Recommendphenotypes)

      flash[:notice] =  "Successfully updated"

      if params[:user][:password] or params[:user][:avatar]
        redirect_to :action => "edit", :id => current_user.id
      else
        respond_to do |format|
          format.js  
          format.html 
        end
      end

    else 

      respond_to do |format|
        format.html do
          if request.xhr?
            flash[:warning] = "Oooops, something went wrong while editing your details"
            render :partial => "edit"
          else
            render
          end
        end
      end
    end
  end

  def check_to_create_phenotype(characteristic, variation, user_id)
    # does the phenotype exist?
    @phenotype = Phenotype.find_by_characteristic(characteristic)
    if @phenotype == nil
      # createphenotype if it doesn't exist
      @phenotype = Phenotype.create(:characteristic => characteristic, :number_of_users => 1)
    end
    @user_phenotype = UserPhenotype.find_by_phenotype_id(@phenotype.id)
    if @user_phenotype == nil
      # create user_phenotype if it doesn't exist
      @user_phenotype = UserPhenotype.create(:user_id => user_id, :variation => variation, :phenotype_id => @phenotype.id)
    else
      # if user_phenotype exists, update
      @user_phenotype.update_attributes(:variation => variation)
    end
  end

  def destroy
    @user = User.find(params[:id])
    # delete the genotype(s)
    @user.genotypes.each do |ug|
      ug.destroy
    end

    flash[:notice] = "Thank you for using openSNP. Goodbye!"

    # disconnect from fitbit if needed
    if @user.fitbit_profile != nil
      Sidekiq::Client.enqueue(FitbitEndSubscription, @user.fitbit_profile.id)
    end

    @user.destroy

    # delete phenotypes without user-phenotypes and update number-of-users
    Sidekiq::Client.enqueue(Fixphenotypes)
    redirect_to root_url
  end

  def remove_help_one
    current_user.update_attribute("help_one",true)
  end

  def remove_help_two
    current_user.update_attribute("help_two",true)
  end

  def remove_help_three
    current_user.update_attribute("help_three",true)
  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def require_owner
    unless current_user == User.find(params[:id])
      store_location
      if current_user
        flash[:notice] = "Redirected to your edit page"
        redirect_to :controller => "users", :action => "edit", :id => current_user.id 
      else
        flash[:notice] = "You need to be logged in"
        redirect_to "/signin"
      end
      return false
    end
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :avatar,
      :delete_avatar,
      :sex,
      :yearofbirth,
      :description,
      :homepages_attributes,
      :message_on_newsletter,
      :message_on_message,
      :message_on_new_phenotype,
      :message_on_phenotype_comment_reply,
      :message_on_snp_comment_reply,
    )
  end
end
