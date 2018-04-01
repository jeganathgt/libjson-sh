#!/bin/bash

. ../include/jshn.sh

json_init

    ##The below JSON is per radio config, This can be repeated n times as per radio present in system, without any changes in C file.

        json_add_string "Radio_Id" "radioId"
        json_add_string "Radio_mac" "radioId"

	
        json_add_string "MAX_BSSID" "MAX_BSSID"
        json_add_string "Radio_mac" "radioId"

json_dump

