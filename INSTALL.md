# Installing openSNP

Hello and thanks so much for your interest in running our code! Maybe even to
contribute to the project. For more details on this see
[CONTRIBUTING.md](https://github.com/openSNP/snpr/blob/master/CONTRIBUTING.md)

## How the site works

The site itself is based on Ruby on Rails (RoR). We usually try to use the
newest version, but after major changes in new version RoR it may sometimes take
a while for the switch to happen.

## Setup

git is needed to download the newest sources:

```
git clone https://github.com/openSNP/snpr.git
```

Afterwards you'll have a new folder called "snpr" (it's not opensnp for
historical reasons, the reason being startups ending with *R* were considered
sexy back when) in which all the files reside.

## Install Dependencies

- [redis](http://redis.io/)
- [hiredis](https://github.com/redis/hiredis)
- [postgres](http://www.postgresql.org/)
- [mailcatcher](https://mailcatcher.me/)

Additionally, you may have to install a couple of development dependencies - `libpq-dev`
and `libsqlite3-dev`. Depending on your operating system these are installed in
different ways.

### RVM

It's easier to use [RVM](https://rvm.io/)  to handle different Ruby versions,
and the repository has all necessary files so that a new installation of RVM
should find what it needs to download and install. There is an installation
manual on the RVM homepage. After a successful installation and once you cd into
the snpr/ directory, RVM should say something about installing the necessary
Ruby version.

Otherwise, change into the cloned `snpr` directory and run the following
commands to install necessary gems.

```
gem install bundler
bundle install
```

## Setup config

All configuration is done via environment variables. A file with a
working environment for development can be found at `.env.example`.
Simply copy it to `.env` to use it as is. The
[dotenv](https://github.com/bkeepers/dotenv) gem will pick it up
and set the environment variables.

Copy `config/database.yml.example` to `config/database.yml` and adapt to your
database setup. Specially, pay attention to the database username and password
configuration. You may have to configure the postgres installation to provide
necessary user privileges for creating database.

## Initialize Database
Before the setup you need initialize the database
```
sudo postgresql-setup --initdb --unit postgresql
```
Add an user to postgres
```
sudo -u postgres createuser username
```
Get into the postgres console
```
sudo -u postgres psql postgres
```
Make your user a super user
```
ALTER USER myuser WITH SUPERUSER;
```
Setup the database
```
bundle exec rake db:setup
```
After the setup the database is already for use.
If you want login to the database and have a look you can use
```
psql snpr_development username
```

## Running the server

For development there's a small bash script called `serverscript` which starts
the Rails server, the Redis server as well as the Sidekiq workers and
Mailcatcher.

```
bash serverscript.sh
```

Voila! If everything worked out right so far, you should see openSNP portal at
[localhost:3000](http://localhost:3000).

Additionally, there are many background tasks which live in `app/workers`, such as
file parsing or talking to various APIs. They are handled by Sidekiq workers.
You can monitor the sidekiq-workers on
[localhost:3000/sidekiq](http://localhost:3000/sidekiq) (useful in killing
leftover tasks) once sidekiq is up and running.

In the development environment, the application will send the emails through
Mailcatcher, which means all emails are just stored locally on your end and can
easily be viewed at [http://127.0.0.1:1080](http://127.0.0.1:1080).

## Talk to us

Please get in touch if you have trouble running openSNP on your end. You can
send a mail to snpr-development@googlegroups.com if you want to discuss with us
(or use the GH issues). There's also info@opensnp.org if something broke on the
webpage itself.

We're also available on Twitter:

@[gedankenstuecke](https://twitter.com/gedankenstuecke)
@[helgerausch](https://twitter.com/helgerausch)
@[philippbayer](https://twitter.com/philippbayer)

[There's also a Gitter](https://gitter.im/openSNP/snpr) where you can talk with us.

## Last words

Thank you very much for your interest in the project and for the help of all
volunteers who've helped us so far! There is a [humans.txt](public/humans.txt)
where we celebrate all of you.

## FAQs

* **I’m getting `FATAL: Peer authentication failed for user "postgres"`**

    Please follow the suggestions
    [here](http://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge)
    to configure your postgres installation. You will also need to [grant](http://dba.stackexchange.com/questions/33285/granting-a-user-account-permission-to-create-databases-in-postgresql)
    `CREATEDB` privilege to the `username` in your `database.yml`.

* **I’m getting a weird error!**

    Please open a new request on GitHub [issue tracker](https://github.com/openSNP/snpr/issues).
