# Minimal Permissions for issuing certificates

Issuer:
```yaml
apiVersion: certmanager.freeipa.org/v1beta1
kind: Issuer
metadata:
  name: freeipa-issuer
spec:
  host: ipa.i.k3test.dns.navy
  user:
    name: freeipa-auth
    key: user
  password:
    name: freeipa-auth
    key: password

  # Optionals
  serviceName: HTTP
  addHost: false
  addService: true
  addPrincipal: true
  ca: k3s
  #Do not check certificate of IPA server
  insecure: true
  #This fixes a bug when adding a service
  ignoreError: true
```
## Sub - CA
(optional) Add a Sub-CA from which to issue certificates for Kubernetes services

## Permissions:
0. Create a Permission "`Service write userCertificate`", which grants write access to the `userCertificate` field of a Service. This is needed to store the created certificate in IPA
1. Create a new Priviledge: Custom K3S Certificate Creation Service
2. Add the following Permissions

- Request Certificate
- Retrieve Certificates from the CA
- Get Certificates status from the CA
- System: Add Services
- Service write userCertificate

3. Create a new Role: cert-manager
4. Add the privilege to this role
