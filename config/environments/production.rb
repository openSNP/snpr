Snpr::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb


  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :info

  # Use a different logger for distributed setups
  config.logger = Logger.new($stdout)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Serve files from /public directory
  config.serve_static_files = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = {
    from: 'no-reply@opensnp.org'
  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Compress JavaScript and CSS
  config.assets.compress = true
  config.assets.js_compressor = :uglifier
  #config.assets.css_compressor = :yui

  # Don't fallback to assets pipeline
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  config.lograge.enabled = true

  # Eager load code on boot.
  config.eager_load = true

  # Make ActiveJob and hence ActionMailer use Sidekiq
  config.active_job.queue_adapter = :sidekiq
end
