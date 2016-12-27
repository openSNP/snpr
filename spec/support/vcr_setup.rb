# frozen_string_literal: true
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_hosts '127.0.0.1', 'codeclimate.com'
end
