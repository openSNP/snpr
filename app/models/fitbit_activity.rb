# frozen_string_literal: true
class FitbitActivity < ActiveRecord::Base
  belongs_to :fitbit_profile

  def self.find_or_create_by_fitbit_profile_id_and_date_logged(fitbit_profile_id, date_logged)
    obj = self.find_by_fitbit_profile_id_and_date_logged( fitbit_profile_id, date_logged ) || self.new(:fitbit_profile_id => fitbit_profile_id, :date_logged => date_logged)
    obj
  end  

end