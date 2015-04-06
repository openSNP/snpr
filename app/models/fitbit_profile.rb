class FitbitProfile < ActiveRecord::Base
  belongs_to :user
  has_many :fitbit_bodies, dependent: :destroy
  has_many :fitbit_activities, dependent: :destroy
  has_many :fitbit_sleeps, dependent: :destroy
end
