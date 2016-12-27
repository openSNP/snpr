# frozen_string_literal: true
namespace :newsletter do
  desc "send newsletter"
  task :send => :environment do
    User.where(:message_on_newsletter => true).find_each do |u|
        UserMailer.newsletter(u).deliver_later
    end
  end
end
