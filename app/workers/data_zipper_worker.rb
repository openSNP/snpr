# frozen_string_literal: true

class DataZipperWorker
  include Sidekiq::Worker
  sidekiq_options queue: :zipfulldata, retry: 0, unique: true, dead: false
  # can't do retry => false.
  # Note with retry disabled, Sidekiq will not track or save any error data for the worker's jobs.
  # dead => false means don't send dead job to the dead queue, we don't care about that

  OUTPUT_DIR = Rails.root.join('public', 'data', 'zip')

  def perform
    DataZipperService.new(output_dir: OUTPUT_DIR, logger: logger).call
  end
end
