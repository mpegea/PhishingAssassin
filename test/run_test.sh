#!/bin/bash

SERVER=SERVER_IP

# Code executed by each test request, that ends writing its own result into a csv file line
function test_request {
    FULL_RESULT=$(spamc --full -d $SERVER -p 783 < $1)
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
    echo "${FILE//,},$SCORE,$RESULT,$EXPECTED" >> /root/out.csv
}

# Print Ascii art header
cat /root/ascii_art.txt

SIZE="$(find /root/dataset/ -name *.eml | wc -l)"
echo -e "*********************************\n"
echo -e " Dataset Size: $SIZE [emails]\n"
echo -e " Analysis Server: $SERVER\n"
echo -e "*********************************\n"


# Field separator
IFS=$'\n'

# Clean older output files
echo -e "-> Cleaning old files..."
truncate -s 0 /root/out.csv
truncate -s 0 /root/result.md

# Send a test request by each email provided inside the dataset
echo -e "-> Analyzing..." 
LIST="$(find /root/dataset/ -name *.eml)"
pids_array=()
echo -e "file, score, result, expected" >> /root/out.csv
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
echo -e "-> Generating results..."
awk -f /root/check_results.awk /root/out.csv

echo -e "-> Done!\n\n"