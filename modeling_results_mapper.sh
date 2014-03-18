#!/bin/bash
# modeling_results_mapper.sh - This script maps a list of output files from
# openModeller to an array of modeling_results objects.
# Receives an occurrences file and the minimum number of occurrences that a 
# species need to have in the occurrences file to be modeled as input.
#
# More about mappers:
# http://swift-lang.org/guides/trunk/userguide/userguide.html#_mappers
#
# See the Swift script to know more about the modeling_results type.

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

# Yields the modeling_results array
awk -F'\t' '/^[0-9]/ { print $2 }' "$i" |
	sed 's/ /_/; s/,//; s/^\n//;' |
	sort |
	uniq -c |
	awk -v "min_occ=$min" '{ if ($1 > min_occ) print $2 }' |
	awk '{ print "["NR"].model output_"$0".xml\n["NR"].map output_"$0".img" }'
