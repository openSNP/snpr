# frozen_string_literal: true
class MoveFrequencyJobsToFrequencyQueue < ActiveRecord::Migration
  def change
    Sidekiq::Queue.new('user_snps').each do |job|
      if job.klass == 'Frequency'
        Frequency.perform_async(*job.args)
        job.delete
      end
    end
  end
end
