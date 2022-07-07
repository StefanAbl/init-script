# OpenVPN Mullvad

Installs openvpn client and connects to Mullvad VPN.

It also blocks most other connections and prevents DNS leaks.

## Variables

```yaml
mullvad:
  account_number: "123456781234"
  ca_crt: |
    -----BEGIN CERTIFICATE-----
    MIIGIzCCBAugAwI0MA0GCSqGSIb3MIGfMQswCQYD
    ...
    H7nDIGdrCC9U/g1LesyKzsG214Xd8m7/7GmJ7nXe5
    -----END CERTIFICATE-----
```

## Output a list of mullvad servers:

Select servers at random max for openvpn is 64
```bash
#!/bin/bash
input="$(curl https://api.mullvad.net/www/relays/all/)"
for i in $(seq 1 64); do
  index=$(echo $(($RANDOM % $(echo "$input" | jq '[ .[] | select( .type | test("openvpn")) ] | length'))))
  ip=$(echo "$input" | jq --arg i $index '[ .[] | select( .type | test("openvpn"))] | .[$i|tonumber]| .ipv4_addr_in')
  echo "  - { ip: $ip, port: \"1195\"" \}
done
```

```bash
for i in $(curl https://api.mullvad.net/www/relays/all/ | jq ' .[] | select( .type | test("openvpn")) | .ipv4_addr_in  '); do echo "  - { ip: $i, port: \"1195\"" \}; done
```
