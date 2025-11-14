#!/usr/bin/env bash

find . -maxdepth 10 -type f -print0 |
while IFS= read -r -d '' file
do
    #echo "File: $file"
    s=$( echo "$file" | sed -e 's/.*-\([0-9]\{8\}T[0-9]\{6\}\)[-\.].*/\1/' )
    if [[ (-n $s) && ($s != $file) ]]
    then
        #echo "S: $s"
        # Date and time
        date="${s:0:4}-${s:4:2}-${s:6:5}:${s:11:2}:${s:13:2}"
        echo "Updating Time: " touch --date "$date" "$file"
        touch --date "$date" "$file"
    else
        s=$( echo "$file" | sed -e 's/.*-\([0-9]\{8\}\)[-\.].*/\1/' )
        if [[ (-n $s) && ($s != $file) ]]
        then
            #echo "S: $s"
            # Date only
            date="${s:0:4}-${s:4:2}-${s:6:2}"
            echo "Updating Date: " touch --date "$date" "$file"
            touch --date "$date" "$file"
	else
	    s=$( echo "$file" | sed -e 's/.*-\([0-9]\{6\}\)[-\.].*/\1/' )
	    if [[ (-n $s) && ($s != $file) ]]
	    then
		#echo "S: $s"
		# Year and month only
		date="${s:0:4}-${s:4:2}-01"
		echo "Updating Date: " touch --date "$date" "$file"
		touch --date "$date" "$file"
	    fi
        fi
    fi
done

