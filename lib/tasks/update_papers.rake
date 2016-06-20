namespace :papers do
  desc 'update papers'
  task update: :environment do
    UpdatePapers.perform_async
  end
end
