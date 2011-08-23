class Message < ActiveRecord::Base
	# from http://stackoverflow.com/questions/5141564/model-users-message-in-rails-3
	belongs_to :user

	scope :sent, where(:sent => true)
	scope :received, where(:sent => false)

	def send_message(from, recipients)
		recipients.each do |r|
			msg = self.clone
			msg.sent = false
			msg.user_id = r
			msg.save
		end
		self.update_attributes :user_id => from.id, :sent => true
	end
end
