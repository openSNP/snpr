# frozen_string_literal: true
namespace :frequencies do
  desc "update papers"
  task :update => :environment do
    Snp.update_frequencies
  end
end
