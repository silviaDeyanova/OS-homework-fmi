#!/bin/bash

if [ ! -f $1 ]; then
    echo "Expected an existing file"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Expected one argument which is file"
    exit 2
fi

filename=$(mktemp)
echo $filename | xargs -I {} mv {} /tmp/data.txt

while read line; do
    if [ $(echo "$line" | egrep -v "^#") ]; then
        date=$(curl $line 2>&1 | egrep -o "[[:digit:]]{1,2}.[[:digit:]]{2}.[[:digit:]]{4}" | awk -F '.' '{if(length($1)==1)print "0"$0;else print $0}' ) 
        category=""
        
        while read code; do
            if [[ $(echo "$code" | egrep -o "<tr class=\"Head1 NewPage H1") ]]; then
                category=$(echo "$code" | head -c 30 | tail -c 3) 
            fi
            if [[ $(echo "$code" | egrep "\"ResLine") ]]; then
                place=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+' | cut -d '+' -f 2 | sed 's/\.//g' )
                names=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+'| cut -d '+' -f 3 | sed 's/, /,/g' | awk -F ',' '{print $2, $1}')
                nationality=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+' | cut -d '+' -f 4)
                call=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+' | cut -d '+' -f 5 | awk '{if($1~"^&nbsp;$")print"";else print $1}')
                time=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+' | cut -d '+' -f 6)
                num=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+' | cut -d '+' -f 7 | awk '{if($1~"^&nbsp;$")print"";else print $1}')
                startNum=$(echo "$code" | sed 's/<[^>]*>/+/g' | tr -s '+' | cut -d '+' -f 8)
                result=$(echo "$date":"$category":"$place":"$names":"$nationality":"$call":"$time":"$num":"$startNum" | sed 's/: /:/g')
                echo "$result"
                echo "$result" >> /tmp/data.txt
            fi
            
        done < <(curl --silent $line)  
    fi
done <$1