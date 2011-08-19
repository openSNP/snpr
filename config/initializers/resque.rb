Dir["#{::Rails.root.to_s}/app/jobs/*.rb"].each { |file| require file }
