require 'email_veracity' # for email-validity
require 'digest' # for password encryption

class User < ActiveRecord::Base

	has_one :phenotype

	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation

	validates :name, :presence => true
	validates :email, :presence => true,
		:uniqueness => { :case_sensitive => false }

	validates :password, :presence => true, :confirmation => true
	before_save :encrypt_password

	# check whether user-supplied password is OK
	def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end

	# log in user
	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
	end

	def self.authenticate_with_salt(id, cookie_salt)
		user = find_by_id(id)
		(user && user.salt == cookie_salt)? user:nil
	end
    
	# check whether email is OK
	def valid_email?(email)
		works = EmailVeracity::Address.new(email)
		return works.valid?
	end
	
	def validate
		unless errors.on(:email)
			unless valid_email?(email)
				errors.add(:email, "seems not to be valid.")
			end
		end
	end

	# now comes lots of magic for secure, salted passwords
	
	private
	
	def encrypt_password
		self.salt = make_salt if new_record?
		self.encrypted_password = encrypt(password)
	end

	def encrypt(string)
		secure_hash("#{salt}--#{string}")
	end

	def make_salt
		secure_hash("#{Time.now.utc}--#{password}")
	end

	def secure_hash(string)
		Digest::SHA2.hexdigest(string)
	end
	
end
