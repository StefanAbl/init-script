#!/bin/bash
device={{update_ip.device}}
ip4File="/tmp/.ip4"
ip6File="/tmp/.ip6"
dynv6="/usr/bin/dynv6.sh"
cf="/usr/bin/cf.sh"

date 
ip4="$(curl -4 https://am.i.mullvad.net)"
ip6=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
echo "ipv4 is $ip4"
echo "ipv6 is $ip6"

touch "$ip4File"
read -r oldip4 < "$ip4File"
touch "$ip6File"
read -r oldip6 < "$ip6File"
if [[ ("$ip4" == "$oldip4") && ("$ip6" == "$oldip6") ]]; then
    echo ipv4 and ipv6 address did not change quitting
    exit
fi

echo "$ip4" > "$ip4File"
echo "$ip6" > "$ip6File"
{%if update_ip.dynv6 %}
{%if update_ip.dynv6.zones %}
{% for zone in update_ip.dynv6.zones %}
$dynv6 hosts "{{zone}}" set ipv4addr "$ip4"
$dynv6 hosts "{{zone}}" set ipv6addr "$ip6"
{% endfor %}
{%endif%}
{%if update_ip.dynv6.records %}
{% for r in update_ip.dynv6.records %}
$dynv6 records update "{{r}}" A "$ip4"
$dynv6 records update "{{r}}" AAAA "$ip6"
{% endfor %}
{%endif%}
{%endif%}

{%if update_ip.cf%}
{%if update_ip.cf.zones %}
{% for zone in update_ip.cf.zones %}
$cf -4 "$ip4" -6 "$ip6" --key "{{update_ip.cf.token}}" --zone "{{ zone.name }}" {% for record in zone.records%} -r "{{record}}"{%endfor%}
{%endfor%}
{%endif%}
{%endif%}