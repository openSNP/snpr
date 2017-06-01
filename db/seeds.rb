# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)
#

if Achievement.all.length == 0
  time = Time.now.utc
  # Ths is written in SQL to prevent Solr from indexing... *le sigh*
  Achievement.connection.execute(<<-SQL)
    INSERT INTO achievements (award, short_name, created_at, updated_at)
    VALUES
      ('Published genotyping', 'pub_gen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Published 10 Mio. SNPs', '10_mio', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Entered first phenotype', '1phen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Entered 5 additional phenotypes', '5phen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Entered 10 additional phenotypes', '10phen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Entered 20 additional phenotypes', '20phen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Entered 50 additional phenotypes', '50phen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Entered 100 additional phenotypes', '100phen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Created a new phenotype', '1addphen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Created 5 new phenotypes', '5addphen', '#{time.iso8601}', '#{time.iso8601}'),
	    ('Created 10 new phenotypes', '10addphen', '#{time.iso8601}', '#{time.iso8601}')
  SQL
end

load 'db/development_seeds.rb' if Rails.env.development?
