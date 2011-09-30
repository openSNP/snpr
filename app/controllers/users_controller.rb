class UsersController < ApplicationController

  before_filter :require_owner, only: [ :update, :destroy, :edit ]
  helper_method :sort_column, :sort_direction
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
    @user = User.create(params[:user])

    if not params[:read]
      flash[:warning] = "You must tick the box to proceed!"
    end

    if params[:read] and @user.save
      flash[:notice] = "Account registered!"
      UserMailer.welcome_user(@user).deliver
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
    @snps = @user.snps.order("#{sort_column} #{sort_direction}").
      paginate(:page => params[:page])
    @received_messages = @user.messages.where(:sent => false).all(:order => "created_at DESC")
    @sent_messages = @user.messages.where(:sent => true).all(:order => "created_at DESC")
    @phenotype_comments = PhenotypeComment.where(:user_id => @user.id).paginate(:page => params[:page])
    @snp_comments = SnpComment.where(:user_id => @user.id)

    # get phenotypes that current_user did not enter yet
    @all_phenotype_ids = []
    Phenotype.find(:all).each do |p| @all_phenotype_ids << p.id 
    end
    @all_user_phenotype_ids = []
    UserPhenotype.find_all_by_user_id(@user.id).each do |up| @all_user_phenotype_ids << up.phenotype_id 
    end  
    @unentered_phenotype_ids = (@all_phenotype_ids | @all_user_phenotype_ids) - (@all_phenotype_ids & @all_user_phenotype_ids)
    @unentered_phenotypes = []
    @unentered_phenotype_ids.each do |up| @unentered_phenotypes << Phenotype.find_by_id(up) end
    @unentered_phenotypes.sort!{ |b,a| a.created_at <=> b.created_at }

    #find all snp-comment-replies that this user got
    @user_snp_comment_ids = []
    @snp_comments.each do |sc| @user_snp_comment_ids << sc.id end		
    @snp_comment_replies = []
    @user_snp_comment_ids.each do |ui| 
      @replies_for_snp = SnpComment.find_all_by_reply_to_id(ui)
      @replies_for_snp.each do |rs|
        @snp_comment_replies << rs
      end
    end  
    @snp_comment_replies.sort! { |b,a| a.created_at <=> b.created_at }
    @paginated_snp_replies = @snp_comment_replies.paginate(:page => params[:page])

    #find all phenotype-comment-replies that this user got
    @user_phenotype_comment_ids = []
    @phenotype_comments.each do |pc| @user_phenotype_comment_ids << pc.id end
    @phenotype_comment_replies = []
    @user_phenotype_comment_ids.each do |pi|
      @replies_for_phenotype = PhenotypeComment.find_all_by_reply_to_id(pi)
      @replies_for_phenotype.each do |rp|
        @phenotype_comment_replies << rp
      end
    end
    @phenotype_comment_replies.sort! { |b,a| a.created_at <=> b.created_at }
    @paginated_phenotype_replies = @phenotype_comment_replies.paginate(:page => params[:page])

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
      respond_to do |format|
        format.html
        format.xml
    end
  end
    
  def update
    @user = User.find(params[:id])
    @pot_delete_phenotype_ids = []
    if params[:user][:user_phenotypes_attributes] != nil
      
      params[:user][:user_phenotypes_attributes].each do |p|  
        @phenotype = Phenotype.find(UserPhenotype.find(p[1]["id"]).phenotype_id)
        @pot_delete_phenotype_ids << @phenotype.id
        if @phenotype.known_phenotypes.include?(p[1]["variation"]) == false
          @phenotype.known_phenotypes << p[1]["variation"]
          @phenotype.number_of_users = UserPhenotype.find_all_by_phenotype_id(@phenotype.id).length
          @phenotype.save
        end
      end
    end
      
    if @user.update_attributes(params[:user])
      @empty_websites = Homepage.find_all_by_user_id_and_url(current_user.id,"")
      @empty_websites.each do |ew| ew.delete end
      
      if @pot_delete_phenotype_ids != []
        @pot_delete_phenotype_ids.each do |pid|
          if UserPhenotype.find_all_by_phenotype_id(pid).length == 0
            Phenotype.delete(pid)
          end
        end
      end
      
      flash[:notice] =  "Successfully updated"
      redirect_to :action => 'edit'
    else
      flash[:notice] = "Oooops, something went wrong while editing your details"
      redirect_to :action => 'edit' 
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
    
    @user.user_achievements.each do |ua|
      UserAchievement.delete(ua)
    end
    
    @messages = Message.find_all_by_user_id(@user_id)
    
    @messages.each do |mt|
      Message.delete(mt)
    end
    
    @user.user_phenotypes.each do |up|
      @phenotype = Phenotype.find_by_id(up.phenotype_id)
      if @phenotype.user_phenotypes.length == 1
        Phenotype.delete(@phenotype)
      end
      UserPhenotype.delete(up)
    end
    flash[:notice] = "Thank you for using openSNP. Goodbye!"
    User.delete(@user)
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

  def sort_column
    Snp.column_names.include?(params[:sort]) ? params[:sort] : "ranking"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
