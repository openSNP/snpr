# Installing openSNP
Hello and thanks so much for your interest in running our code! Maybe even to contribute to the project. For more details on this see [CONTRIBUTING.md](https://github.com/gedankenstuecke/snpr/blob/master/CONTRIBUTING.md)

## How the site works

The site itself is based on Ruby on Rails (RoR). We usually try to use the newest version, but after major changes in new version RoR it may sometimes take a while for the switch to happen.

## Setup

git is needed to download the newest sources:

```
git clone git@github.com:gedankenstuecke/snpr.git
```

Afterwards you'll have a new folder called "snpr" (it's not opensnp for historical reasons) in which all the files reside.

## Install Dependencies

- redis
- hiredis
- postgres

Depending on your operating system these are installed in different ways.

### RVM

It's easier to use [RVM](https://rvm.io/)  to handle different Ruby versions, and the repository has all necessary files so that a new installation of RVM should find what it needs to download and install. There is an installation manual on the RVM homepage. After a successful installation and once you cd into the snpr/ directory, RVM should say something
about installing the necessary Ruby version.

## Setup Config

All configuration is done via environment variables. A file with a
working environment for development can be found at `.env.example`.
Simply copy it to `.env` to use it as is. The
[dotenv](https://github.com/bkeepers/dotenv) gem will pick it up
and set the environment variables.

Copy `config/database.yml.example` to `config/database.yml` and adapt to
your database setup if needed (note: it's not needed on my Fedora machine, experience may vary).

## Initialize Database

```
bundle exec rake db:setup
```

## Running the server

For development there's a small bash script called `serverscript` which starts the Rails server, the Redis server as well as the Sidekiq workers.

```
bash serverscript.sh
```

There are many background tasks which live in app/workers, such as file parsing or talking to various APIs, which are handled by Sidekiq workers. You can monitor the sidekiq-workers on [localhost:3000/sidekiq](http://localhost:3000/sidekiq) (useful in killing leftover tasks) once sidekiq is up and running.

## Last words

Thank you very much for your interest in the project and for the help of all volunteers who've helped us so far! There is a humans.txt where we celebrate all of you.
