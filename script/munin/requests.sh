#!/usr/bin/env sh

case $1 in
	config)
		cat <<EOM
graph_title requests per second
graph_vlabel requests
graph_category opensnp.org
req.label requests
req.type DERIVE
req.min 0
EOM
	exit 0;;
esac

req=$(egrep -c '^Started ' /srv/www/snpr/shared/log/production.log)
echo "req.value ${req}"
