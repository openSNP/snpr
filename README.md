# openSNP [![Build Status](https://travis-ci.org/gedankenstuecke/snpr.svg?branch=master)](https://travis-ci.org/gedankenstuecke/snpr)

a repository to which users can upload their SNP-sets (and exome-VCFs) from
23andme, deCODEme, FamilyTreeDNA, AncestryDNA and IYG-format (for participants
of EBI genotyping). On upload, SNPs are annotated using the PLoS and
Mendeley-APIs to show users the newest scientific research results on their
SNPs. Each SNP is also linked to the relevant page on SNPedia. SNPs are ranked
according to how many results could be gathered for SNPedia, PLoS and Mendeley
(in that order). Users can send each other private messages as well as comment
on SNPs and Phenotypes.

Users can enter phenotypes to assist future research. Search is handled using
postgres directly via pg_search.

RSS-feeds are provided for uploaded genotypes and new publications.

You can monitor the sidekiq-workers on
[localhost:3000/sidekiq](http://localhost:3000/sidekiq) (useful in killing
leftover tasks)

To load all standard achievements into the database run

```
rake db:seed OR rake db:setup (which also sets up the entire db)
```

# Getting Started

## Install Dependencies

- redis
- hiredis
- postgres

## Setup Config

All configuration is done via environment variables. A file with a
working environment for development can be found at `.env.example`.
Simply copy it to `.env` to use it as is. The
[dotenv](https://github.com/bkeepers/dotenv) gem will pick it up
and set the environment variables.

Copy `config/database.yml.example` to `config/database.yml` and adapt to
your database setup.

## Initialize Database

```
bundle exec rake db:setup
```

## Run Tests

```
bundle exec rake
```
This runs RSpec tests as well as the **legacy** test/unit ones.

# Usage

You need to have the following running to ensure that everything works:

```
redis-server

sidekiq -q preparse,2 -q parse,2 -q deletegenotype -q fitbit -q fixphenotypes -q frequency -q genomegov -q mailnewgenotype -q mendeley_details -q mendeley -q pgp -q plos_details -q plos -q zipfulldata -q snpedia -q zipgenotyping -C config/sidekiq.yml -e development

rails s(erver)
```

Note: "serverscript" starts all these in detached screen-sessions.

To see all rake-tasks:

```
rake -vT
```

# Deployment

Deployment is handled via capistrano (thanks Helge!). The most important capistrano tasks:

```
cap deploy
```

deploys the newest version to production.

```
cap sidekiq:{start,stop,restart}
```

handles the Sidekiq workers. Has to be started on reboot!

# Dependencies

For Fedora 19:

```
yum install postgresql postgresql-devel hiredis hiredis-devel libxslt-devel libxslt libxml2 libxml2-devel
```

# Contribute

If you want to contribute to openSNP, you are more than welcome to do so:

* We use [the issue tracker at GitHub](https://github.com/gedankenstuecke/snpr/issues)
  for everything that needs to be done. And there is the [mailing list](https://groups.google.com/forum/#!forum/snpr-development) which we use for discuss running openSNP.org and other issues not directly related to the code-base.
* Running `rake notes` may give you some hints about things that can be
  improved.
* In order to help improving the overall code style, take a look into
  `.rubocop_todo.yml`. In order to learn what it is all about take a
  look at [rubocop](https://github.com/bbatsov/rubocop) and specifically
  [this section of the README](https://github.com/bbatsov/rubocop#automatically-generated-configuration)
  to learn more about it.
