#!/bin/bash

. ../include/jshn.sh

json_init "array"

json_add_array
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_close_array
json_add_int "radio_id" 1
json_add_array
json_add_array
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_close_array
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_add_int "radio_id" 2
json_close_array
#export -p
json_dump
