# IP update
Updates the IP of a domain or record of a domain with the machines, public IPv4 and IPv6 address

## Variables
```yaml
update_ip:
  device: eth0 #The device from which to take the IPv6 addr
  dynv6:
    token: #token for the dynv6 REST API or variable to load it from
    records: # List of records of zones in dynv6
      - something.centostest.v6.rocks
    zones: #List of dynv6 zones
      - centostest.v6.rocks
  cf:
    token: #the secret key
    zones:
      - name: example.com
        records:
          - "@"
          - "www"
```
