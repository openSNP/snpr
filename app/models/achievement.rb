class Achievement < ActiveRecord::Base
	attr_accessible :award,:short_name
   has_many :user_achievements

   searchable do
      text :award
   end
end
