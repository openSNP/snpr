#!/usr/bin/env sh

case $1 in
	config)
		cat <<EOM
graph_title requests per minute
graph_vlabel requests
graph_category opensnp.org
req.label requests
req.type DERIVE
req.min 0
EOM
	exit 0;;
esac

echo -n 'req.value '
wc -l /srv/www/snpr/shared/log/production.log | cut -d ' ' -f 1
