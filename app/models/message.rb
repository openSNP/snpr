# frozen_string_literal: true
class Message < ActiveRecord::Base
  # from http://stackoverflow.com/questions/5141564/model-users-message-in-rails-3
  belongs_to :user

  scope :sent, -> { where(sent: true) }
  scope :received, -> { where(sent: false) }

  # note: messages are cloned so that copies are kept on delete
  # change in Rails 3.1: .clone was replaced by .dup, .clone is only shallow copy
  def send_message(from, recipient)
    msg = self.dup
    # false means that the message was received,
    # true means that the message was sent
    msg.user_id = recipient
    msg.sent = false
    msg.to_id = recipient
    msg.from_id = from
    msg.user_has_seen = false
    msg.save
    if User.find_by_id(recipient).try(:message_on_message) == true
      UserMailer.new_message(recipient,msg.id).deliver_later
    end
    self.update_attributes from_id: from, sent: true, to_id: recipient, user_has_seen: true
  end
end
