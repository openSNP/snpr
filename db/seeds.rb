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
	Achievement.create(:award => "Published genotyping", :short_name => "pub_gen")
	Achievement.create(:award => "Published 10 Mio. SNPs", :short_name => "10_mio")
	Achievement.create(:award => "Entered first phenotype", :short_name => "1phen")
	Achievement.create(:award => "Entered 5 additional phenotypes", :short_name => "5phen")
	Achievement.create(:award => "Entered 10 additional phenotypes", :short_name => "10phen")
	Achievement.create(:award => "Entered 20 additional phenotypes", :short_name => "20phen")
	Achievement.create(:award => "Entered 50 additional phenotypes", :short_name => "50phen")
	Achievement.create(:award => "Entered 100 additional phenotypes", :short_name => "100phen")
	Achievement.create(:award => "Created a new phenotype", :short_name => "1addphen")
	Achievement.create(:award => "Created 5 new phenotypes", :short_name => "5addphen")
	Achievement.create(:award => "Created 10 new phenotypes", :short_name => "10addphen")
end
