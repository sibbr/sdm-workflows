#!/bin/bash

awk -F'\t' '/^[0-9]/ { print $2 }' "$2" | sed "s/ /_/" | sort | uniq | awk '{ print "["NR"] request_"$0".txt" }'
