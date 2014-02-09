#!/bin/bash

# process mapper arguments
while [ $# -gt 0 ]; do
    case $1 in
	-i)              i=$2;;
	-min)            min=$2;;
        *)               echo "$0: bad mapper args" 1>&2
	                 exit;;
    esac
    shift 2
done

#awk -F'\t' '/^[0-9]/ { print $2 }' "$2" |\
# sed "s/ /_/" |\
# sort |\
# uniq -c |\
# awk '{ print "["NR"].model output_"$0".xml\n["NR"].map output_"$0".img" }'

awk -F'\t' '/^[0-9]/ { print $2 }' "$i" | \
    sed "s/ /_/" | \
    sed "s/,//" | \
    sed "s/^\n//" | \
    sort | \
    uniq -c | \
    awk -v min_occ=$min '{ if ($1 > min_occ) print $2 }' | \
    awk '{ print "["NR"].model output_"$0".xml\n["NR"].map output_"$0".img" }'
#awk '{print "["NR"] request_"$1".txt" }'

