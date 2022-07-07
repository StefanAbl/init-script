# External Proxy
This role will setup the main entrypoint for the homelab
## ACME validation
Certificates are obtained via [acme.sh](https://github.com/acmesh-official/acme.sh.)
Validation can be done via http01 validation or dns validation.
This can be specified on a per virtual server basis.
For dns validation the necessary environment variables should be included in `acmesh.env_vars`
Additionally the dns api which should be used by acme.sh should be specified, e.g. use Cloudflare with dns_cf.
A full ist can be found [here](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)

## Variables
```yaml
acmesh:
  env_vars:
    - name: DYNV6_TOKEN
      value: ""
streams:
  - name: unifi.thorn.dynv6.net
    value: |
      listen 3478 udp;
      proxy_pass 192.168.2.15:3478;
servers:
  - name: something.centostest.v6.rocks #The name of the server
    upstream: https://10.13.2.101:8920
      #How acme.sh should verify the server either http or dns
    verification: dns
      #If verification is dns, which dns APi should acme.sh use
    api: dns_dynv6
    allow_embedding: True do not add X-Frame-Options SAMEORIGIN
    extras_location: # extras to include in the location block
    #extras to include in the server block
    extras: |
      add_header Content-Security-Policy "default-src https: data: blob:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com/cv/js/sender/v1/cast_sender.js https://www.youtube.com/iframe_api https://s.ytimg.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self' http://localhost:* file:";
      location /metrics {
        return 404;
      }
```
