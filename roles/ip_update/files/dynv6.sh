#!/bin/bash
echo $@
if [[ -z $debug ]]; then
    debug=false
fi
dynv6_api="https://dynv6.com/api/v2"
args=("$@")
#. acme.sh
_debug() {
    if $debug; then
        echo "Debug: $@"
    fi
}
_err() {
    echo "Err: $@"
}

_contains() {
    _str="$1"
    _sub="$2"
    echo "$_str" | grep -- "$_sub" >/dev/null 2>&1
}

_dynv6_rest() {
    local m=$1    #method GET,POST,DELETE or PUT
    local ep="$2" #the endpoint
    local data="$3"
    _debug "$ep"

    token_trimmed=$(echo "$dynv6_token" | tr -d '"')

    _debug "$data"
    local file=$(mktemp)
    local code="$(curl -sS -o $file -w "%{http_code}" --location --request $m "$dynv6_api/$ep" \
        --header 'Authorization: Bearer '"$token_trimmed" \
        --header 'Content-Type: application/json' \
        --data-raw "$data")"

    if [ "$?" != "0" ]; then
        _err "error $ep"
        _debug response "$response"
        exit 1
    fi
    if [ $code != "200" ]; then
        _err "There was an error while interacting with the API"
        _err "Response code $code"
        cat $file
        _err "Exiting now"
        exit 1
    else
        response="$(cat $file)"
    fi
    _debug response "$response"
    return 0
}
#usage: _set_record TXT _acme_challenge.www longvalue 12345678
#zone id is optional can also be set as vairable bevor calling this method
_set_record() {
    type="$1"
    record="$2"
    value="$3"
    if [ "$4" ]; then
        _zone_id="$4"
    fi
    data="{\"name\": \"$record\", \"data\": \"$value\", \"type\": \"$type\"}"
    echo "$data"
    _dynv6_rest POST "zones/$_zone_id/records" "$data"
}

_update_record() {
    local type="$1"
    local value="$2"
    data="{\"data\": \"$value\", \"type\": \"$type\"}"
    _debug "$data"
    _dynv6_rest PATCH "zones/$_zone_id/records/"$_record_id "$data"
}

_del_record() {
    _zone_id=$1
    _record_id=$2
    _dynv6_rest DELETE zones/"$_zone_id"/records/"$_record_id"
}

#usage _get_record_id $zone_id $record
# where zone_id is thevalue returned by _get_zone_id
# and record ist in the form _acme.www for an fqdn of _acme.www.example.com
# returns _record_id
_get_record_id() {
    local _zone_id="$1"
    local record="$2"
    local type="$3"
    local value="$4" # if this is given the value must also match
    _debug "Looking for record $record of type $type in zone $_zone_id"

    _dynv6_rest GET "zones/$_zone_id/records"
    _record_id="$(echo "$response" | tr '}' '\n' | grep "\"name\":\"$record\"")"
    if [ ! -z "$value" ]; then
        _record_id="$(echo "$_record_id" | grep "\"data\":\"$value\"")"
    fi
    if [ ! -z "$type" ]; then
        _record_id="$(echo "$_record_id" | grep "\"type\":\"$type\"")"
    fi
    _record_id="$(echo $_record_id | tr ',' '\n' | grep id | tr -d '"' | tr -d 'id:')"
    #_record_id="${_record_id#id:}"
    if [ -z "$_record_id" ]; then
        return 1
    fi
    _debug "record id: $_record_id"
    return 0
}

get_host_names() {
    _dynv6_rest GET zones
    #echo $json | sed 's/},{/\n/g' | tr -d '[]{}"'
    _hosts="$(echo $response | sed 's/},{/\n/g' | tr -d '[]{}"' | sed 's/,/\n/g' | grep 'name:' | sed 's/name://g')"
}

#get the zoneid for a specifc record or zone
#usage: _get_zone_id §record
#where $record is the record to get the id for
#returns _zone_id the id of the zone
#returns _zone_name the name of the zon e.g. example.dynv6.net
_get_zone_id() {
    record="$1"
    _debug "getting zone id for $record"
    _dynv6_rest GET zones

    zones="$(echo "$response" | tr '}' '\n' | tr ',' '\n' | grep name | sed 's/\[//g' | tr -d '{' | tr -d '"')"
    #echo $zones

    local selected=""
    for z in $zones; do
        z="${z#name:}"
        _debug zone: "$z"
        if _contains "$record" "$z"; then
            _debug "$z found in $record"
            selected="$z"
        fi
    done
    if [ -z "$selected" ]; then
        _err "no zone found"
        return 1
    fi
    _debug "Zone name: $selected"
    _zone_name="$selected"
    zone_id="$(echo "$response" | tr '}' '\n' | grep "$selected" | tr ',' '\n' | grep id | tr -d '"')"
    _zone_id="${zone_id#id:}"
    _debug "zone id: $_zone_id"
}

###############
#START
###############

for ((i = 0; i < ${#args[@]}; i++)); do
    _debug $i ${args[$i]}
done
if [ ${args[0]} = "hosts" ]; then
    if [[ "${#args[@]}" -eq 1 ]]; then
        echo "Getting host names"
        get_host_names
        echo "Hosts: $_hosts"
        echo "Done. Only read hosts"
        exit 0
    fi
    _get_zone_id ${args[1]}

    #Set the addresses of the zone
    if [ "${args[2]}" = "set" ]; then
        _debug "Manipulating zone itself"
        if [[ "${#args[@]}" -eq 3 ]]; then
            echo "Done"
            exit 0
        fi
        if [ "${args[3]}" = "ipv4addr" ]; then
            echo "Setting ipv4addr to ${args[4]}"
            msg='{"ipv4address": "'"${args[4]}"'"}"'
            _dynv6_rest PATCH zones/$_zone_id "$msg"
            exit 0
        fi
        if [ "${args[3]}" = "ipv6addr" ]; then
            echo "Setting ipv4addr to ${args[4]}"
            msg='{"ipv6prefix": "'"${args[4]}"'"}"'
            _dynv6_rest PATCH zones/$_zone_id "$msg"
            exit 0
        fi
    fi

    #Manipulate the records of the zone
    _debug arg legth "${#args[@]}"
    if [ "${args[2]}" = "records" ]; then
        _debug "Changing records of zone"
        if [ "${args[3]}" = "set" ]; then
            _debug "Changing existing record or creating new record"
            record="${args[4]}"
            _get_record_id $_zone_id $record
            type="${args[5]}"
            type="$(echo $type | tr '[a-z]' '[A-Z]')"
            data="${args[7]}"
            if [ -z "$_record_id" ]; then
                _debug "Record does not exist yet. Creating it"
                _set_record $type "$record" "$data"
            else
                _debug "Updating record of type $type with data $data"
                _update_record $type "$data" "$record"
            fi
        elif [ "${args[3]}" = "del" ]; then
            record="${args[4]}"
            _debug "Deleting record"
            record="${args[4]}"
            if ! _get_record_id $_zone_id $record; then
                echo "No such record. Nothing to do"
            else
                _del_record $_zone_id $_record_id
            fi
        fi
    fi
    exit 1
elif [ ${args[0]} = "records" ]; then
    record="${args[2]}"
    if [[ -z $record ]]; then
        _err "Need second argument"
        exit 1
    fi
    #Get zone of record
    _debug getting zone id
    if ! _get_zone_id "$record"; then
        _err "Could not find a matching zone for this record. Maybe this token is not authorized to access it."
        exit 1
    fi
    _debug changin record to short for
    record="$(echo $record | sed "s/.$_zone_name//g")"
    _debug record is now $record
    type="${args[3]}"
    type="$(echo $type | tr '[a-z]' '[A-Z]')"
    data="${args[4]}"
    _debug "Using type $type and data $data"
    #What action to perform on record
    if [ ${args[1]} = "create" ]; then
        if [[ -z $type || -z $data ]]; then
            _err "Need more arguments"
            exit 1
        fi
        _set_record "$type" "$record" "$data"
        exit 0
    elif [ ${args[1]} = "update" ]; then
        if [[ -z $type || -z $data ]]; then
            _err "Need more arguments"
            exit 1
        fi
        if ! _get_record_id "$_zone_id" "$record" "$type"; then
            _err "Could not find this record. Are you sure it exists"
            exit 1
        fi
        if [ $(echo "$_record_id" | wc -l) -gt 1 ]; then
            _err "More than one record present please specify further"
            exit 1
        else
            _debug "Record identified"
            _debug "Setting record $record to $type $data"
            _update_record "$type" "$data"
            exit $?
        fi
    elif [ ${args[1]} = "set" ]; then
        if [[ -z $type || -z $data ]]; then
            _err "Need more arguments"
            exit 1
        fi
        if ! _get_record_id "$_zone_id" "$record" "$type"; then
            #The record does not yet exist
            _debug "Record does not exist. Creating it."
            _set_record "$type" "$record" "$data"
        else
            if [ $(echo "$_record_id" | wc -l) -gt 1 ]; then
                _err "More than one record present please specify further"
                exit 1
            else
                _debug "Record identified"
                _debug "Setting record $record to $type $data"
                _update_record "$type" "$data"
                exit $?
            fi
        fi
    fi

    exit 1
fi
echo '
Usage:
Set dynv6 token as environment variable dynv6_token="seceret" ./dynv6.sh ...
Manipluate zones:
dynv6.sh hosts ZONE_NAME set [ipv4addr IPV4, ipv6addr IPV6]

Manipluate records of zones:
Create or update an existing record:
dynv6.sh hosts ZONE_NAME records set RECORD_NAME [A, AAAA, CNAME, MX, TXT] data RECORD_DATA
Delete all records of this name and type
dynv6.sh hosts ZONE_NAME records del RECORD_NAME [A, AAAA, CNAME, MX, TXT]
Manipulate records:
Example:
dynv6.sh records create "www.example.com" A "127.0.0.1"
dynv6.sh records update "www.example.com" A "127.0.0.1"
Set will create the record if it does not exist and update it if it does
dynv6.sh records set "www.example.com" A "127.0.0.1"
'
exit 0
