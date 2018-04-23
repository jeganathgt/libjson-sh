#!/bin/bash

. ./json_my_new.sh
#. ./jshn.sh
json_init "object"
#json_init

json_add_object "radio_2G"
json_add_string "bandwidth" "20Mhz"
json_add_string "country" "EU"
json_close_object
json_add_object "radio_5G"
json_add_string "bandwidth" "40Mhz"
json_add_string "country" "US"
json_close_object
json_add_object "operating_class"
json_close_object
json_dump
