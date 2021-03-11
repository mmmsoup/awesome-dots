#!/bin/sh

display_time=$(date +"%H:%M")
echo -e "time_widget.text = \"$display_time\"" | awesome-client

while true; do
	second=$(date +"%S")
	echo $second
	if [[ second -le 15 ]]; then
		sleep 30
	elif [[ second -le 30 ]]; then
		sleep 15
	elif [[ second -le 45 ]]; then
		sleep 10
	else
		sleep "$((60-$second))"
		display_time=$(date +"%H:%M")
		echo -e "time_widget.text = \"$display_time\"" | awesome-client
	fi
done
