#!/bin/sh

json_init()
{
	json_cleanup
	export -- \
		JSON_CURSOR="TOP_VAR" \
		VALUE_TOP_VAR="JSON" \
		TYPE_TOP_VAR="$1" \
		KEY_TOP_VAR="TOP_VAR" \
		KEYS_TOP_VAR=  \
		SEQ_NUM=0  \
		JSON_PREV_TOP_VAR= \
		JSON_ERROR= 
}

json_cleanup()
{
	unset \
		KEYS_TOP_VAR \
		VALUE_TOP_VAR \
		TYPE_TOP_VAR \
		KEY_TOP_VAR \
		SEQ_NUM \
		JSON_ERROR \
		JSON_CURSOR \
		JSON_PREV_TOP_VAR
}

json_get_type()
{
    eval "$1=\"\$TYPE_$2\""
}

json_append()
{
    eval "$1=\"\${$1} \$2\""
}

json_get_error()
{
    eval "$1=\"\$JSON_ERROR\""
}

json_get_keys()
{
    eval "$1=\"\$KEYS_$2\""
}

json_get_prev()
{
    eval "$1=\"\$JSON_PREV_$2\""
}

json_table_length()
{
    local keys
    local i 

    json_get_keys keys $2 
    if [ ! -z "$keys" ]; then
        #printf "KEYS:$keys\n"
        for i in $keys
        do
             eval "$1=\"\$(($1 + 1))\""
        done
    else
        eval "$1=0"
    fi
}

__json_close_generic()
{
    local cursor_value
    local prev_cursor

    json_get_cursor cursor_value
    json_get_prev prev_cursor $cursor_value
    json_set_cursor $prev_cursor
}

json_close_array()
{
    __json_close_generic
}


json_close_object()
{
    __json_close_generic
}

__json_add_generic()
{
    local key_name=$1
    local cursor_value
    local prev_table_type
    local value
    local seq_no
    local obj_type=$3
    local new_cursor

    json_get_error value 
    if [ "$value" = "error" ]; then
        #Do not proceed if any error in JSON sequence
	return
    fi

    json_get_cursor cursor_value
    json_get_type prev_table_type $cursor_value

    #printf "add_string prev_table_type=$prev_table_type, cursor=$cursor_value\n"
    
    json_update_seq_number
    json_get_seq_number seq_no

    new_cursor="${key_name}_$seq_no"
    json_append "KEYS_$cursor_value" $new_cursor

    eval "export -- TYPE_$new_cursor=\"\$obj_type\"  KEY_$new_cursor=\"\$key_name\"  VALUE_$new_cursor=\"\$2\"  JSON_PREV_$new_cursor=\"\$cursor_value\"" 

}

json_add_string()
{
    __json_add_generic $1 "$2" string

}

json_add_int()
{
    __json_add_generic $1 $2 "integer"
}


json_add_boolean()
{

    __json_add_generic $1 $2 "boolean"
}


json_add_double()
{
    __json_add_generic $1 $2 "double"
}


json_add_array()
{
    local key_name=$1
    local cursor_value
    local prev_table_type
    local value
    local seq_no
    local new_cursor

    json_get_cursor cursor_value
    json_get_type prev_table_type $cursor_value

    #printf "prev_table_type=$prev_table_type\n"

    json_get_error value 
    if [ "$value" = "error" ]; then
        #Do not proceed if any error in JSON sequence
	return
    fi

    [ ! -z $key_name ] && [ $prev_table_type = "array" ]
    ## Array table at top will not have key named array and key named object within
    if [ $? -eq 0 ]; then
	printf "ERROR: Array table at top will not have key named array and key named object within\n"
	eval "JSON_ERROR=\"error\""
	return 
    fi

    [ -z $key_name ] && [ $prev_table_type = "object" ]
    ## Object table at top should have key named array and key named object within
    if [ $? -eq 0 ]; then
	printf "ERROR: Object table at top should have key named array and key named object within\n"
	eval "JSON_ERROR=\"error\""
	return 
    fi

    json_update_seq_number
    json_get_seq_number seq_no

    if [ -z $key_name ]; then
	## Control comes here meaning that the previous table must be "array"
        new_cursor="${cursor_value}_$seq_no"
    else
	new_cursor="${key_name}_$seq_no"
    fi

    #printf "key_name=$key_name\n"

    #printf "new_cursor=$new_cursor\n"

    json_append "KEYS_$cursor_value" $new_cursor

    eval "export -- TYPE_$new_cursor=\"array\"  KEY_$new_cursor=\"\$key_name\"  KEYS_$new_cursor=  VALUE_$new_cursor=  JSON_PREV_$new_cursor=\"\$cursor_value\"" 

    json_set_cursor $new_cursor
}


json_add_object()
{
    local key_name=$1
    local cursor_value
    local prev_table_type
    local value
    local seq_no
    local new_cursor

    json_get_cursor cursor_value
    json_get_type prev_table_type $cursor_value

    #printf "prev_table_type=$prev_table_type\n"

    json_get_error value 
    if [ "$value" = "error" ]; then
        #Do not proceed if any error in JSON sequence
	return
    fi

    [ ! -z "$key_name" ] && [ $prev_table_type = "array" ]
    ## Array table at top will not have key named array and key named object within
    if [ $? -eq 0 ]; then
	printf "ERROR: Array table at top will not have key named array and key named object within\n"
	eval "JSON_ERROR=\"error\""
	return 
    fi

    [ -z $key_name ] && [ $prev_table_type = "object" ]
    ## Object table at top should have key named array and key named object within
    if [ $? -eq 0 ]; then
	printf "ERROR: Object table at top should have key named array and key named object within\n"
	eval "JSON_ERROR=\"error\""
	return 
    fi

    json_update_seq_number
    json_get_seq_number seq_no

    if [ -z $key_name ]; then
	## Control comes here meaning that the previous table must be "array"
        new_cursor="$cursor_value_$seq_no"
    else
	new_cursor="${key_name}_$seq_no"
    fi

    #printf "new_cursor=$new_cursor\n"
    #printf "key_name=$key_name\n"

    json_append "KEYS_$cursor_value" $new_cursor

    eval "export -- TYPE_$new_cursor=\"object\"  KEY_$new_cursor=\"\$key_name\"  KEYS_$new_cursor=  VALUE_$new_cursor=  JSON_PREV_$new_cursor=\"\$cursor_value\"" 

    json_set_cursor $new_cursor

}

json_get_value()
{
	eval "$1=\"\$VALUE_$2\""
}

json_get_cursor()
{
	eval "$1=$JSON_CURSOR"
}

json_set_cursor()
{
	eval "export JSON_CURSOR=\"\$1\""
}

json_get_curr_type()
{
	json_get_cursor cursor_value
	#printf "cursor_value=$cursor_value\n" 
	eval "$1=\"\$TYPE_$cursor_value\""
}

json_update_seq_number()
{
	eval "SEQ_NUM=\"\$(($SEQ_NUM + 1))\""
}

json_get_seq_number()
{
	eval "$1=\"\$SEQ_NUM\""
}

json_get_orig_key()
{
	eval "$1=\"\$KEY_$2\""
}

json_dump_table()
{
	local length=0
	local type
	local cursor
	local Keys
	local key
	local top_level_type
	local length

        json_get_cursor cursor
        json_get_keys Keys $cursor

	#printf "prev_type==$1\n"

	json_get_curr_type top_level_type

	#printf "top_level_type==$top_level_type\n"
	json_table_length length $cursor

	for i in $Keys
	do
		if [ $top_level_type = "object" ]; then
		    ## if the previous table is "object", only then print "key" 
		    json_get_orig_key key $i
		    printf "\"$key\": "
		fi 
		json_get_type type $i
		if [ "$type" = "array" ]; then
		    printf "[ "
		    json_set_cursor $i
		    json_dump_table
		    json_set_cursor $cursor
		    printf " ]"
		elif [ "$type" = "object" ]; then
		    printf "{ "
		    json_set_cursor $i
		    json_dump_table
		    json_set_cursor $cursor
		    printf " }"
		elif [ "$type" = "string" ]; then
		    json_get_value value $i
		    printf "\"$value\""
		elif [ "$type" = "integer" ]; then
		    json_get_value value $i
		    printf "$value"
		elif [ "$type" = "boolean" ]; then
		    json_get_value value $i
                    [ $value -eq 1 ] && printf "true"
                    [ $value -eq 1 ] || printf "false"
		elif [ "$type" = "double" ]; then
		    json_get_value value $i
		    printf "$value"
		fi

		length=$(($length-1))
		if [ $length -ne 0 ]; then
		    printf ", "
		fi
	done
}

json_dump()
{
	local top_value
	local type
	local current_cursor

	json_get_cursor current_cursor

	#Reset the JSON_CUR to default value which will be helpful for parsing
	json_set_cursor TOP_VAR

	#get current TYPE
	json_get_curr_type type

	#printf "type==$type\n"
	if [ "$type" = "array" ] ; then
		printf "[ "
	elif [ "$type" = "object" ]; then
		printf "{ "
	fi

	json_dump_table

	#Reset the curser value back 
	json_set_cursor $current_cursor

	if [ "$type" = "array" ] ; then
		printf " ]"
	elif [ "$type" = "object" ]; then
		printf " }"
	fi
	printf "\n"
	##export -p
}
