Server: bundle exec rails s
Solr: bundle exec rake sunspot:solr:run
Redis: redis-server /usr/local/etc/redis.conf
Sidekiq: bundle exec sidekiq -q preparse,2 -q parse,2 -q deletegenotype -q fitbit -q fixphenotypes -q frequency -q genomegov -q mailnewgenotype -q mendeley_details -q mendeley -q pgp -q plos_details -q plos -q zipfulldata -q snpedia -q zipgenotyping