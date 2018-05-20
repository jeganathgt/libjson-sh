#!/bin/bash

. ../include/jshn.sh

json_init "object"

json_add_object
json_add_string "radio" "radio_2G"
json_add_string "channel" "1 2 3 4"
json_close_object
#json_add_object "radio_2G"
#export -p
json_dump
