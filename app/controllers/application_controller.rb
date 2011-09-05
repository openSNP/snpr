class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user

  def create_genotype_hash(phenotypes)
	# returns hash containing all genotypes 
	# linked to a certain phenotype
	genotypes = []
	phenotypes = [] << phenotypes
	phenotypes.each do |p|
		# get all associated users
		users = []
		p.user_phenotypes.each do |up|
			users <<  User.find_by_id(up.user_id)
		end
		# get associated genotypes
		users.each do |u|
			genotypes << u.genotypes
		end
	end
	return genotypes
  end

	def bundle(phenotypes)
		# uses above hash to create zip-file on-the-fly
		# and sends it to the user
		genotypes = create_genotype_hash(phenotypes)
		genotypes = genotypes[0]
		if not genotypes.empty?
			file_name = "genotypes.zip"
			# put a temporary random file into /tmp
			t = Tempfile.new('temp_genotypes-#{Time.now.to_s + rand(9999).to_s}') 
			Zip::ZipOutputStream.open(t.path) do |z|
				genotypes.each do |gen|
						title = gen.user_id.to_s + "."  + gen.filetype + "."+ gen.id.to_s
						z.put_next_entry(title)
						z.print IO.read("#{RAILS_ROOT}/public/data/" + title)
					end
				end
			send_file t.path, :type => 'application/zip',
				:disposition => 'attachment',
				:filename => file_name
			end
	end 
  private

  def current_user_session
	  return @current_user_session if defined?(@current_user_session)
	  @current_user_session = UserSession.find
  end

  def current_user
	  return @current_user if defined?(@current_user)
	  @current_user = current_user_session && current_user_session.user
  end

  def require_user
	  unless current_user
		  store_location
		  flash[:warning] = "You must be logged in to access this page!"
		  redirect_to root_url
		  return false
	  end
  end

  def require_no_user
	  if current_user
		  store_location
		  flash[:warning] = "You must be logged out to access this page"
		  redirect_to current_user
		  return false
	  end
  end

  def store_location
	  session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
	  redirect_to(session[:return_to] || default)
	  session[:return_to] = nil
  end
end
