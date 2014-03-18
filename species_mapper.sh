#!/bin/bash
# species_mapper.sh - This script maps a list of request filenames to
# an array. Receives an occurrences file and the minimum number of occurrences
# that a species need to have in the occurrences file to be modeled as input.
#
# More about mappers:
# http://swift-lang.org/guides/trunk/userguide/userguide.html#_mappers

HELP_MSG="
$(sed -n '2,/^#$/p' "$0" | sed 's/^# //; $d')

Usage: $(basename "$0") -i occurrences_file [-m number_of_occurrences] 
"

# Process mapper arguments
while [ $# -gt 0 ]; do
	case "$1" in
		-h | --help)
			echo "$HELP_MSG"
			exit 0
		;;
		-i)		i="$2" ;;
		-m)		min="$2" ;;
		*)
			echo "$0: bad mapper args" 1>&2
			exit 1
		;;
	esac
	shift 2
done

# Yields the request filenames array
awk -F'\t' '/^[0-9]/ { print $2 }' "$i" |
	sed 's/ /_/; s/,//; s/^\n//;' |
	sort |
	uniq -c |
	awk -v "min_occ=$min" '{ if ($1 > min_occ) print $2 }' |
	awk '{print "["NR"] request_"$1".txt" }'
