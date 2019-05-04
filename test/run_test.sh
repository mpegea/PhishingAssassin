#!/bin/bash

# Code executed by each test request, that ends writing its own result into a csv file
function test_request {
    FULL_RESULT=$(spamc --full -d phishing_assassin -p 783 < $1)
	SCORE=$(echo $FULL_RESULT | cut -d'/' -f1)
	SCORE=${SCORE%.*}
	if [ $SCORE -gt 5 ]
		then
			RESULT='1'
		else
			RESULT='0'
	fi
	if [[ $FILE == *"phishing"* ]];
		then
			EXPECTED='1'
		else
			EXPECTED='0'
	fi
    echo "$FILE,$SCORE,$RESULT,$EXPECTED" >> /root/out.csv
}

# Field separator
IFS=$'\n'

# Clean older output files
truncate -s 0 /root/out.csv
truncate -s 0 /root/result.md

# Send a test request by each email provided inside the dataset 
LIST="$(find /root/dataset/ -name *.eml)"
pids_array=()
for FILE in $LIST;
	do
		test_request $FILE &
    	pids_array+=($!)
	done
for pid in ${pids_array[*]};
	do
    	wait $pid
	done

# Generate a Markdown file with the results obtained
awk -f /root/check_results.awk /root/out.csv