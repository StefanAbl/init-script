#!/bin/bash
records=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -4 | --ipv4)
        ipv4="$2"
        shift # past argument
        shift # past value
        ;;
    -6 | --ipv6)
        ipv6="$2"
        shift # past argument
        shift # past value
        ;;
    -k | --key)
        token="$2"
        shift # past argument
        shift # past value
        ;;
    -z | --zone)
        zone="$2"
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

# get the zone id for the requested zone
zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "Zoneid for $zone is $zoneid"

for dnsrecord in "${records[@]}"; do
    case $dnsrecord in
    *@*)
        echo "found \"@\" in ${dnsrecord}"
        dnsrecord="${dnsrecord##@.}"
        ;;
    esac

    if [ -n "$ipv4" ]; then
        # get the dns record id
        dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

        echo "DNSrecordid for $dnsrecord is $dnsrecordid"
        # update the record
        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ipv4\",\"ttl\":1,\"proxied\":false}" | jq
    fi
    if [ -n "$ipv6" ]; then
        # get the dns record id
        dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=AAAA&name=$dnsrecord" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

        echo "DNSrecordid for $dnsrecord is $dnsrecordid"
        # update the record
        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"AAAA\",\"name\":\"$dnsrecord\",\"content\":\"$ipv6\",\"ttl\":1,\"proxied\":false}" | jq
    fi
done
