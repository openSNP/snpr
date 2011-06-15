class Phenotype < ActiveRecord::Base
   belongs_to :user


   # split the string from the database to an array
   serialize :variations 

   # put in our default values
   after_initialize :default_values

   private

   def default_values
	   # if variations is empty, put in our default array
	   self.variations ||= { :haircolor => "", :eyecolor => "", :skincolor => "", :bloodtype => ""}
   end

end
