# frozen_string_literal: true
namespace :dump do
  desc 'dump all the data'
  task full: :environment do
    Zipfulldata.perform_async
  end
end
