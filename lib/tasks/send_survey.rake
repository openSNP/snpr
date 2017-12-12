# frozen_string_literal: true
namespace :survey do
  desc 'send survey'
  task :send => :environment do
    # invoke script with rake survey:send EXCLUDEFILE=/path/to/file.txt
    # read list of users to exclude
    # should contain one user-ID per line
    exclude_users = if ENV['EXCLUDEFILE']
                      File.readlines(ENV['EXCLUDEFILE']).map(&:chomp!)
                    else
                      []
                    end

    # send survey to each user that
    # a) allows us emailing them
    # b) has genetic data
    # c) is not already in the DB
    User.where(:message_on_newsletter => true).find_each do |u|
      unless exclude_users.include?u.id.to_s
    #    unless u.genotypes.empty?
          UserMailer.survey(u).deliver_now
          # wait for one minute so we don't crash the google mail daily limit
          sleep(1.minute)
        end
    #  end
    end
  end
end
