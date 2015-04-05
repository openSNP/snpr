namespace :papers do
  desc 'update papers'
  task update: :environment do
    Snp.update_papers
  end
end
