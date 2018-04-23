#!/bin/bash

. ./json_my_new.sh

json_init "object"

json_add_object "radio_2G"
json_add_string "radio" "radio_2G"
json_add_string "channel" "1 2 3 4"
json_close_object

json_add_object "radio_5G"
json_add_string "radio" "radio_5G"
json_add_string "channel" "36 40 44 48"
json_close_object

json_add_array "operating_class"
json_add_string "class" "81"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10 11 12 13"
json_close_array

json_add_array "operating_class"
json_add_string "class" "82"
json_add_string "channel" "14"
json_close_array

#json_add_object "radio_2G"
#export -p
json_dump
