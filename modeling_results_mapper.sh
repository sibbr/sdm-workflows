#!/bin/bash
awk -F'\t' '/^[0-9]/ { print $2 }' "$2" | sed "s/ /_/" | sort | uniq | awk '{ print "["NR"].model output_"$0".xml\n["NR"].map output_"$0".img" }'
