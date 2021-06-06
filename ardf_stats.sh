#!/bin/bash

if [ ! -f $1 ]; then
    echo "Expected an existing file"
    exit 1
fi

if [ $# -ne 5 ] && [ $# -ne 3 ]; then
    echo "Expected 3 or 5 arguments"
    exit 2
fi

if [ $2 != "top_places" ] && [ $2 != "parts" ]; then
    echo "Second argument has to be \"top_places\" or \"parts\""
    exit 3
fi

if [ $2 = "top_places" ] && [[ -z $3 || ! $(echo "$3" | egrep "^[A-Z]{1}[0-9]+$") || ! $(echo "$4" | egrep "^[0-9]+$")  || ! $(echo "$5" | egrep "^[0-9]+$") ]]; then
    echo "Wrong input"
    exit 4
fi

if [ $2 = "parts" ] && [[ -z $3 || $(echo "$3" | egrep "^[0-9]+$") ]]; then
    echo "Wrong input"
    exit 5
fi

if [ $2 = "top_places" ]; then
    result=$(cat "$1" | egrep "$3")
    while read line; do
        if [ $(echo "$line" | cut -d ":" -f3 | egrep "[[:digit:]]+") ] && [ $(echo "$line" | cut -d ":" -f3) -le $4 ]; then 
            newResult=$newResult$'\n'$(echo "$line" | cut -d: -f4)
        fi
    done < <(echo "$result")
    echo "$newResult" | tail -n +2 | sort | uniq -c | sort -rn -k1 | head -n $5 | tr -s ' '

elif [[ $2 = "parts" ]]; then
    catAndDate=$(cat "$1" | egrep "$3" | awk -F ':' '{print $2, $1}' | sort -t ' ' -k 1 | uniq)
    output=""
    while read line; do
        result=""
        dates=""
        category=$(echo "$line" | cut -d ' ' -f 1)
        while read code; do
            if [[ $(echo "$code" | egrep "$category") ]]; then
                dates=$dates$'\n'$(echo "$code" | cut -d ' ' -f 2)
            fi  
        done < <(echo "$catAndDate")

        while read date; do
            result=$result,"$date"
        done < <(echo "$dates" | tail -n +2 | sort -n -t '.' -k3 -k2 -k1)

        output=$output$'\n'$(echo "$category $(echo "$result" | cut -d ',' -f 2- | sed 's/,/, /g')")
    done < <(echo "$catAndDate")
    echo "$output" | tail -n +2 | uniq
fi