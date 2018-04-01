#!/bin/bash

. ../include/jshn.sh

json_init

    json_add_object "subobj1"
    ##The below JSON is per radio config, This can be repeated n times as per radio present in system, without any changes in C file.
        json_add_string "Radio_Id" "radioId"

        json_add_string "MAX_BSSID" "MAX_BSSID"

        json_add_string "radio" "radio_2G"
        json_add_string "supported_bandwidth" "40"

        json_add_string "regulatory_domain" "EU"

        json_add_string "channel_list" "1 2 3  5 6 7 8 9 10 11 12 13"

    json_close_object

    json_add_object "subobj2"
    ##The below JSON is per radio config, This can be repeated n times as per radio present in system, without any changes in C file.
        json_add_string "Radio_Id" "radioId2"

        json_add_string "MAX_BSSID" "MAX_BSSID2"

        json_add_string "radio" "radio_5G"
        json_add_string "supported_bandwidth" "160"

        json_add_string "regulatory_domain" "EU"

        json_add_string "channel_list" "36 40 44 48 52 56 50 64 100 104 108 112"

    json_close_object

json_dump

