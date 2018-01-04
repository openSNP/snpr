# frozen_string_literal: true

if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ENV.fetch('SENTRY_DSN')
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end

  # Notify Sentry of a new release.
  Net::HTTP.post(
    URI.parse(ENV.fetch('SENTRY_RELEASE_WEBHOOK')),
    { 'version' => File.read('REVISION').strip }.to_json,
    'Content-Type' => 'application/json'
  )
end
