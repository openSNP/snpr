class UserMailer < ActionMailer::Base
default :from => "donotreply@opensnp.org"

	def password_reset_instructions(user)
	  @user = user
		mail(:subject	=> "openSNP.org Password Reset Instructions", :to => user.email)
	end
	
	def welcome_user(user)
	  @user = user
	  mail(:subject => "Welcome to openSNP.org", :to => user.email)
  end
  
  def genotyping_results(target_address,link,phenotype_name,variation)
    @link = link
    @phenotype_name = phenotype_name
    @variation = variation
    mail(:subject => "openSNP.org: The data you requested is ready to be downloaded",:to => target_address)
  end
  
  def no_genotyping_results(target_address,phenotype_name,variation)
    @phenotype_name = phenotype_name
    @variation = variation
    mail(:subject => "openSNP.org: No genotyping files match your search",:to => target_address)
  end
end
