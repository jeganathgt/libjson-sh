#!/bin/bash

. ../include/jshn.sh

json_init "array"

json_add_array
json_add_int "bandwidth" 20
json_add_double "efficiency" 12.5
json_close_array

json_add_array
json_add_int "bandwidth" 40
json_add_double "efficiency" 18.8
json_close_array

json_dump
