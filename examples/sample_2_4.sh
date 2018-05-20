#!/bin/bash

. ../include/jshn.sh

json_init "array"

json_add_object "radio_2G"
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_close_object
#export -p
json_dump
