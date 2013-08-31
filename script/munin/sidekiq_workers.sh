#!/usr/bin/env sh

case $1 in
	config)
		cat <<EOM
graph_title Sidekiq workers
graph_vlabel #
graph_category opensnp.org
idle.label idle
busy.label busy
EOM
	exit 0;;
esac


ps=$(ps -eo command | grep sidekiq | grep busy | cut -d '[' -f 2)
busy=$(echo $ps | cut -d ' ' -f 1)
total=$(echo $ps | cut -d ' ' -f 3)
idle=$(($total-$busy))

echo "busy.value ${busy}"
echo "idle.value ${idle}"
