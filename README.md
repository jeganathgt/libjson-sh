# libjson-sh

This is linux shell based json library, by which we can construct complete json object within the shell without the need for compilation.

Since this is linux shell based library, it can be easily portable across all linux latforms.

Provided we should include "./include/jshn.sh" file.

The below are some of the well known library api:
- json_init
- json_add_object 
- json_close_object
- json_add_string
- json_add_array
- json_close_array

Here is the example:
====================

. ./include/jshn.sh

json_init "object"
    json_add_array "AP_Autoconfig_config"

    json_add_object
        json_add_string "Radio_Id" "radioId"

        json_add_string "MAX_BSSID" "MAX_BSSID"

        json_add_string "radio" "radio_2G"
        json_add_string "supported_bandwidth" "40"

        json_add_string "regulatory_domain" "EU"

        json_add_string "channel_list" "1 2 3 4 5 6 7 8 9 10 11 12 13"

    json_close_object

    json_add_object
        json_add_string "Radio_Id" "radioId"

        json_add_string "MAX_BSSID" "MAX_BSSID"

        json_add_string "radio" "radio_5G"
        json_add_string "supported_bandwidth" "160"

        json_add_string "regulatory_domain" "EU"

        json_add_string "channel_list" "36 40 44 48 52 56 60 64 100 104 108 112 116 132 136 140"

    json_close_object
    json_close_array

json_dump

output:
=======

{ "AP_Autoconfig_config": [ { "Radio_Id": "radioId", "MAX_BSSID": "MAX_BSSID", "radio": "radio_2G", "supported_bandwidth": "40", "regulatory_domain": "EU", "channel_list": "1 2 3  5 6 7 8 9 10 11 12 13" }, { "Radio_Id": "radioId", "MAX_BSSID": "MAX_BSSID", "radio": "radio_5G", "supported_bandwidth": "160", "regulatory_domain": "EU", "channel_list": "36 40 44 48 52 56 60 64 100 104 108 112 116 132 136 140" } ] }

