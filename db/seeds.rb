# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#
#User.create(:name => "bla", :email => "abc@def.com", :password => "abc", :password_confirmation => "abc",  :has_sequence => true)
if Achievement.all.length == 0
	Achievement.create(:award => "Published genotyping")
	Achievement.create(:award => "Published 10 Mio. SNPs")
	Achievement.create(:award => "Entered variation on standard phenotypes")
	Achievement.create(:award => "Entered 5 additional phenotypes")
	Achievement.create(:award => "Entered 10 additional phenotypes")
	Achievement.create(:award => "Entered 20 additional phenotypes")
	Achievement.create(:award => "Entered 50 additional phenotypes")
	Achievement.create(:award => "Entered 100 additional phenotypes")
	Achievement.create(:award => "Created a new phenotype")
	Achievement.create(:award => "Created 5 new phenotypes")
	Achievement.create(:award => "Created 10 new phenotypes")
end
