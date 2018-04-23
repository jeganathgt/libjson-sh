#!/bin/bash

. ./json_my_new.sh

var="array object"
while :
do
for i in $var
do
json_init "$i"

if [[ $i = "array" ]] ; then

json_add_object

json_add_object "repeater2" 
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_close_object
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"

json_close_object

json_add_object
json_add_array "repeater1"
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_add_array
json_add_string "bandwidth" "20Mhz"
json_add_string "channel" "1 2 3 4 5 6 7 8 9 10"
json_close_array
json_close_array
json_close_object
else
json_add_object "radio_2G"
json_add_string "radio" "radio_2G"
json_add_string "channel" "1 2 3 4"

json_add_object "operating_class"
 json_add_string "class" "81"

 json_add_object "supported_channels"
   json_add_string "channel_list" "1 2 3 4 5 6 7 8 9 10 11 12 13"

     json_add_object "eirp"
       json_add_string "power" "-29dBm"
     json_close_object

   json_close_object
 json_close_object
json_close_object

fi
export -p
json_dump
sleep 1
done
done
