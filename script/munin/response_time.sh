#!/usr/bin/env bash

case $1 in
	config)
		cat <<EOM
graph_title Response time
graph_vlabel ms
graph_scale no
graph_category opensnp.org
time0.label /
EOM
	exit 0;;
esac

function request {
  t0=$(date +%s%3N)
  curl "https://opensnp.org${1}" >/dev/null 2>&1
  t1=$(date +%s%3N)
  echo $(($t1-$t0))
}


echo "time0.value $(request "/")"
