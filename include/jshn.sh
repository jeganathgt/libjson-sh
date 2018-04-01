# functions for parsing and generating json

_json_get_var() {
	# dest=$1
	# var=$2
	eval "$1=\"\$${JSON_PREFIX}$2\""
}

_json_set_var() {
	# var=$1
	local ___val="$2"
	eval "${JSON_PREFIX}$1=\"\$___val\""
}

__jshn_raw_append() {
	# var=$1
	local value="$2"
	local sep="${3:- }"

	eval "export -- \"$1=\${$1:+\${$1}\${value:+\$sep}}\$value\""
}

_jshn_append() {
	# var=$1
	local _a_value="$2"
	eval "${JSON_PREFIX}$1=\"\${${JSON_PREFIX}$1} \$_a_value\""
}

_get_var() {
	# var=$1
	# value=$2
	eval "$1=\"\$$2\""
}

_set_var() {
	# var=$1
	local __val="$2"
	eval "$1=\"\$__val\""
}

_json_inc() {
	# var=$1
	# dest=$2

	eval "${JSON_PREFIX}$1=\$(( \${${JSON_PREFIX}$1:-0} + 1))${2:+; $2=\"\$${JSON_PREFIX}$1\"}"
}

_json_add_generic() {
	# type=$1
	# name=$2
	# value=$3
	# cur=$4

	local var
	if [ "${4%%[0-9]*}" = "JSON_ARRAY" ]; then
		_json_inc "SEQ_$4" var
	else
		local name="${2//[^a-zA-Z0-9_]/_}"
		[[ "$name" == "$2" ]] || export -- "${JSON_PREFIX}NAME_${4}_${name}=$2"
		var="$name"
	fi

	local cur_var=
	export -- \
		"${JSON_PREFIX}${4}_$var=$3" \
		"${JSON_PREFIX}TYPE_${4}_$var=$1"
	_jshn_append "JSON_UNSET" "${4}_$var"
	_jshn_append "KEYS_$4" "$var"
}

_json_add_table() {
	# name=$1
	# type=$2
	# itype=$3
	local cur seq

	_json_get_var cur JSON_CUR
	_json_inc JSON_SEQ seq

	local table="JSON_$3$seq"
	_json_set_var "UP_$table" "$cur"
	export -- "${JSON_PREFIX}KEYS_$table="
	unset "${JSON_PREFIX}SEQ_$table"
	_json_set_var JSON_CUR "$table"
	_jshn_append "JSON_UNSET" "$table"

	_json_add_generic "$2" "$1" "$table" "$cur"
}

_json_close_table() {
	local _s_cur

	_json_get_var _s_cur JSON_CUR
	_json_get_var "${JSON_PREFIX}JSON_CUR" "UP_$_s_cur"
}

json_set_namespace() {
	local _new="$1"
	local _old="$2"

	[ -n "$_old" ] && _set_var "$_old" "$JSON_PREFIX"
	JSON_PREFIX="$_new"
}

json_cleanup() {
	local unset

	_json_get_var unset JSON_UNSET
	for tmp in $unset JSON_VAR; do
		unset \
			${JSON_PREFIX}UP_$tmp \
			${JSON_PREFIX}KEYS_$tmp \
			${JSON_PREFIX}SEQ_$tmp \
			${JSON_PREFIX}TYPE_$tmp \
			${JSON_PREFIX}NAME_$tmp \
			${JSON_PREFIX}$tmp
	done

	unset \
		${JSON_PREFIX}JSON_SEQ \
		${JSON_PREFIX}JSON_CUR \
		${JSON_PREFIX}JSON_UNSET
}

json_init() {
	json_cleanup
	export -- \
		${JSON_PREFIX}JSON_SEQ=0 \
		${JSON_PREFIX}JSON_CUR="JSON_VAR" \
		${JSON_PREFIX}KEYS_JSON_VAR= \
		${JSON_PREFIX}TYPE_JSON_VAR=
}

json_add_object() {
	_json_add_table "$1" object TABLE
}

json_close_object() {
	_json_close_table
}

json_add_array() {
	_json_add_table "$1" array ARRAY 
}

json_close_array() {
	_json_close_table
}

json_add_string() {
	local cur
	_json_get_var cur JSON_CUR
	_json_add_generic string "$1" "$2" "$cur"
}

json_add_int() {
	local cur
	_json_get_var cur JSON_CUR
	_json_add_generic int "$1" "$2" "$cur"
}

json_add_boolean() {
	local cur
	_json_get_var cur JSON_CUR
	_json_add_generic boolean "$1" "$2" "$cur"
}

json_add_double() {
	local cur
	_json_get_var cur JSON_CUR
	_json_add_generic double "$1" "$2" "$cur"
}

json_dump_table()
{
	local value=0
	local first_cur=0
	local loop_count=0
	local total_length=0
	local __type=0
	local obj_type=0

	json_get_keys indexes 

        #Find total length of indexes
        for i in $indexes
        do
                ((total_length=total_length+1))
        done

        for i in $indexes
        do
                json_get_var value $i
                json_get_type __type $i
		[ $1 = "array" ] || printf "\"$i\": "
                if [ "$__type" = "array" ]; then
		    printf "[ "
		    _json_get_var first_cur JSON_CUR
		    _json_set_var JSON_CUR $value
                    json_dump_table $__type
		    _json_set_var JSON_CUR $first_cur
		    printf " ]"
                elif [ "$__type" = "object" ]; then
		    printf "{ "
		    _json_get_var first_cur JSON_CUR
		    _json_set_var JSON_CUR $value
                    json_dump_table $__type
		    _json_set_var JSON_CUR $first_cur
		    printf " }"
                elif [ "$__type" = "string" ]; then
                    printf "\"$value\""
                elif [ "$__type" = "boolean" ]; then
                    [ $value -eq 1 ] && printf "true"
                    [ $value -eq 1 ] || printf "false"
                elif [ "$__type" = "double" ]; then
		    printf "%f" $value
                elif [ "$__type" = "int" ]; then
                    printf "$value"
                fi

                ((loop_count=loop_count + 1))

                #Last element of JSON data model should not end with ","
                if [ $loop_count -lt $total_length ]; then
                        printf ", "
                fi

        done
}

json_dump() {

	##Get the backup of original JSON_CUR value
	_json_get_var first_cur JSON_CUR
	printf "{ "
		json_dump_table "object"
	printf " }\n"
	_json_set_var JSON_CUR $first_cur
}

json_get_type() {
	local __dest="$1"
	local __cur

	_json_get_var __cur JSON_CUR
	local __var="${JSON_PREFIX}TYPE_${__cur}_${2//[^a-zA-Z0-9_]/_}"
	eval "export -- \"$__dest=\${$__var}\"; [ -n \"\${$__var+x}\" ]"
}

json_get_keys() {
	local __dest="$1"
	local _tbl_cur

	if [ -n "$2" ]; then
		json_get_var _tbl_cur "$2"
	else
		_json_get_var _tbl_cur JSON_CUR
	fi
	local __var="${JSON_PREFIX}KEYS_${_tbl_cur}"
	eval "export -- \"$__dest=\${$__var}\"; [ -n \"\${$__var+x}\" ]"
}

json_get_values() {
	local _v_dest="$1"
	local _v_keys _v_val _select=
	local _json_no_warning=1

	unset "$_v_dest"
	[ -n "$2" ] && {
		json_select "$2" || return 1
		_select=1
	}

	json_get_keys _v_keys
	set -- $_v_keys
	while [ "$#" -gt 0 ]; do
		json_get_var _v_val "$1"
		__jshn_raw_append "$_v_dest" "$_v_val"
		shift
	done
	[ -n "$_select" ] && json_select ..

	return 0
}

json_get_var() {
	local __dest="$1"
	local __cur

	_json_get_var __cur JSON_CUR
	local __var="${JSON_PREFIX}${__cur}_${2//[^a-zA-Z0-9_]/_}"
	eval "export -- \"$__dest=\${$__var:-$3}\"; [ -n \"\${$__var+x}\${3+x}\" ]"
}

json_get_vars() {
	while [ "$#" -gt 0 ]; do
		local _var="$1"; shift
		if [ "$_var" != "${_var#*:}" ]; then
			json_get_var "${_var%%:*}" "${_var%%:*}" "${_var#*:}"
		else
			json_get_var "$_var" "$_var"
		fi
	done
}

json_select() {
	local target="$1"
	local type
	local cur

	[ -z "$1" ] && {
		_json_set_var JSON_CUR "JSON_VAR"
		return 0
	}
	[[ "$1" == ".." ]] && {
		_json_get_var cur JSON_CUR
		_json_get_var cur "UP_$cur"
		_json_set_var JSON_CUR "$cur"
		return 0
	}
	json_get_type type "$target"
	case "$type" in
		object|array)
			json_get_var cur "$target"
			_json_set_var JSON_CUR "$cur"
		;;
		*)
			[ -n "$_json_no_warning" ] || \
				echo "WARNING: Variable '$target' does not exist or is not an array/object"
			return 1
		;;
	esac
}

json_is_a() {
	local type

	json_get_type type "$1"
	[ "$type" = "$2" ]
}
