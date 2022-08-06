# Cert-Manager

Install Cert-Manager and FreeIPA issuer to automatically request certificates from FreeIPA.

## Prerequisites
- The kubernetes workers running the controller for the issuing system must be joined to the FreeIPA domain, for the certificate of the FreeIPA server to be recognized

## Installation
Installation of Cert-Manager and the FreeIPA issuer is automated. However first a service user has to be created in FreeIPA with the permissions detailed in [minimalPermissions.md](minimalPermissions.md).

### How to use

Secure an Ingress resources
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    #Specify the name of the issuer to use must be in the same namespace
    cert-manager.io/issuer: freeipa-issuer
    #The group of the outof tree issuer is needed for cert-manager to find it
    cert-manager.io/issuer-group: certmanager.freeipa.org
    #Specify a common name for the certificate
    cert-manager.io/common-name: www.exapmle.com

spec:
  #placing a host in the TLS config will indicate a certificate should be created
  tls:
    - hosts:
      - www.exapmle.com
      #The certificate will be stored in this secret
      secretName: example-cert
  rules:
    - host: www.exapmle.com
      http:
        paths:
          - path: /
            backend:
              serviceName: backend
              servicePort: 80

```
