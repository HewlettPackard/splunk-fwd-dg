#!/bin/bash

x=5   	# initialize x to 5 : dwell multiplier
y=$1   	# initialize y to $1 args1

mul=$(($x * $y))   # multiply the values of x and y and assign it to variable mul

# start the docker containers
for ((i = 1; i <= $y; i++)); do
	docker run --name splunk-fwd-$i -d my_fwd > /dev/null &
	sleep 1
done
 
# wait : let the containers cook a moment
sleep $mul

# configure docker containers
for ((i = 1; i <= $y; i++)); do
	docker exec splunk-fwd-$i entrypoint.sh splunk add forward-server 1.1.1.1:9997 -auth admin:changeme > /dev/null &
    sleep 5
    docker exec splunk-fwd-$i entrypoint.sh splunk add monitor /opt/perfmon/sample_data -index docker_sandbox > /dev/null &
    sleep 5
    docker exec   -d splunk-fwd-$i /bin/bash /opt/perfmon/bin/auto
    sleep 5
done
