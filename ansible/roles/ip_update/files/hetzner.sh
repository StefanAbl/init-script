#!/bin/bash
# Source: https://github.com/filiparag/hetzner_ddns

self='hetzner_ddns'
interval="60"

POSITIONAL=()
records=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -4 | --ipv4)
        ipv4_cur="$2"
        shift # past argument
        shift # past value
        ;;
    -6 | --ipv6)
        ipv6_cur="$2"
        shift # past argument
        shift # past value
        ;;
    -k | --key)
        key="$2"
        shift # past argument
        shift # past value
        ;;
    -d | --domain)
        domain="$2"
        shift # past argument
        shift # past value
        ;;
    -r | --records)
        records+=("$2") #Use @ for domain itself
        shift           # past argument
        shift           # past value
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# Read variabels from configuration file

# Check dependencies
if ! command -v curl >/dev/null ||
    ! command -v awk >/dev/null ||
    ! command -v jq >/dev/null; then
    echo >&2 'missing dependency'
    exit 1
fi

# Check logging support
if ! touch "/var/log/$self.log"; then
    echo >&2 'unable to open logfile'
    exit 2
fi

get_zone() {
    # Get zone ID
    zone="$(
        curl "https://dns.hetzner.com/api/v1/zones" \
            -H "Auth-API-Token: $key" 2>/dev/null |
            jq -r '.zones[] | .name + " " + .id' |
            awk "\$1==\"$domain\" {print \$2}"
    )"
    if [ -z "$zone" ]; then
        return 1
    else
        printf '[%s] Zone for %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" \
            "$domain" "$zone"
    fi
}

get_record() {
    # Get record IDs
    if [ -n "$zone" ]; then
        record_ipv4="$(
            curl "https://dns.hetzner.com/api/v1/records?zone_id=$zone" \
                -H "Auth-API-Token: $key" 2>/dev/null |
                jq -r '.records[] | .name + " " + .type + " " + .id' |
                awk "\$1==\"$1\" && \$2==\"A\" {print \$3}"
        )"
        record_ipv6="$(
            curl "https://dns.hetzner.com/api/v1/records?zone_id=$zone" \
                -H "Auth-API-Token: $key" 2>/dev/null |
                jq -r '.records[] | .name + " " + .type + " " + .id' |
                awk "\$1==\"$1\" && \$2==\"AAAA\" {print \$3}"
        )"
    fi
    if [ -z "$record_ipv4" ] && [ -z "$record_ipv6" ]; then
        return 1
    else
        printf '[%s] IPv4 record for %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1.$domain" \
            "${record_ipv4:-(missing)}"
        printf '[%s] IPv6 record for %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1.$domain" \
            "${record_ipv6:-(missing)}"
    fi
}

get_records() {
    # Get all record IDs
    for n in "${records[@]}"; do
        if get_record "$n"; then
            records_ipv4="$records_ipv4$n=$record_ipv4 "
            records_ipv6="$records_ipv6$n=$record_ipv6 "
        else
            printf '[%s] Missing both records for %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" \
                "$n.$domain"
        fi
    done
}

get_record_ip_addr() {
    # Get record's IP address
    if [ -n "$record_ipv4" ]; then
        ipv4_rec="$(
            curl "https://dns.hetzner.com/api/v1/records/$record_ipv4" \
                -H "Auth-API-Token: $key" 2>/dev/null |
                jq -r '.record.value'
        )"
    fi
    if [ -n "$record_ipv6" ]; then
        ipv6_rec="$(
            curl "https://dns.hetzner.com/api/v1/records/$record_ipv6" \
                -H "Auth-API-Token: $key" 2>/dev/null |
                jq -r '.record.value'
        )"
    fi
    if [ -z "$ipv4_rec" ] && [ -z "$ipv6_rec" ]; then
        return 1
    fi
}


set_record() {
    # Update record if IP address has changed
    if [ -n "$record_ipv4" ] && [ -n "$ipv4_cur" ] && [ "$ipv4_cur" != "$ipv4_rec" ]; then
        curl -X "PUT" "https://dns.hetzner.com/api/v1/records/$record_ipv4" \
            -H 'Content-Type: application/json' \
            -H "Auth-API-Token: $key" \
            -d "{
            \"value\": \"$ipv4_cur\",
            \"ttl\": $interval,
            \"type\": \"A\",
            \"name\": \"$n\",
            \"zone_id\": \"$zone\"
            }" 1>/dev/null 2>/dev/null &&
            printf "[%s] Update IPv4 for %s: %s => %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" \
                "$n.$domain" "$ipv4_rec" "$ipv4_cur"
    fi
    if [ -n "$record_ipv6" ] && [ -n "$ipv6_cur" ] && [ "$ipv6_cur" != "$ipv6_rec" ]; then
        curl -X "PUT" "https://dns.hetzner.com/api/v1/records/$record_ipv6" \
            -H 'Content-Type: application/json' \
            -H "Auth-API-Token: $key" \
            -d "{
            \"value\": \"$ipv6_cur\",
            \"ttl\": $interval,
            \"type\": \"AAAA\",
            \"name\": \"$n\",
            \"zone_id\": \"$zone\"
            }" 1>/dev/null 2>/dev/null &&
            printf "[%s] Update IPv6 for %s: %s => %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" \
                "$n.$domain" "$ipv6_rec" "$ipv6_cur"
    fi
}

pick_record() {
    # Get record ID from array
    echo "$2" |
        awk "{
        for(i=1;i<=NF;i++){
            n=\$i;gsub(/=.*/,\"\",n);
            r=\$i;gsub(/.*=/,\"\",r);
            if(n==\"$1\"){
                print r;break
            }
        }}"
}

set_records() {
    # Update all records if possible
    for n in "${records[@]}"; do
        record_ipv4="$(pick_record "$n" "$records_ipv4")"
        record_ipv6="$(pick_record "$n" "$records_ipv6")"
        if [ -n "$record_ipv4" ] || [ -n "$record_ipv6" ]; then
            get_record_ip_addr && set_record
        fi
    done
}

printf '[%s] Started Hetzner DNS update\n' "$(date '+%Y-%m-%d %H:%M:%S')"

while ! get_zone || ! get_records; do
    sleep $((interval / 2 + 1))
done

set_records
sleep "$interval"
