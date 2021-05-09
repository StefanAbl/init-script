# Cert-Manager
## Prerequisites
- The kubernetes workers running the controller for the issuing system must be joined to the FreeIPA domain, for the certificate of the FreeIPA server to be recognized

## Installation
#### Install cert-manager
Install with
```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.0/cert-manager.yaml
```
Verify installation with
```bash
k get pods --namespace cert-manager
```

#### Install freeipa-issuer

Install the issuer system
```bash
./kustomize build . | k apply -f -
```

In FreeIPA create a user with the permissions detailed in [minimalPermissions.md](minimalPermissions.md)

Add a secret with the base64 encoded password and username

```bash
echo "Enter FreeIPA user name for issuer"; \
read user; \
echo "Enter password for this user"; \
read pass; \
sudo k3s kubectl create secret generic freeipa-auth --from-literal=user="$user" --from-literal=password="$pass" --dry-run -o yaml | sudo k3s kubectl apply -n freeipa-issuer-system -f - ;\
unset user pass
```

Create a new issuer
```bash
k apply -f issuer.yml
```
### How to use

Secure an Ingress resources
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
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



## Own issues
- [x] container does not accept self signed certificate (Fixed by joining hosts to domain)
- [ ] skip_host_check option is not set even when addHost is false
- [ ] add an endpoint to which DNS is created when adding a service

# Issues to report
1. Documentation missing dependency kustomize
2. Missing field in issuer
error: error validating "issuer.yml": error validating data: ValidationError(Issuer.spec): missing required field "ignoreError" in org.freeipa.certmanager.v1beta1.Issuer.spec; if you choose to ignore these errors, turn validation off with --validate=false
3. controller docker image not found
4. kubernetes hosts have to be joined into FreeIPA domain, otherwise it cannot connect because the FreeIPA certificate is not present, option to add ipa ca.crt as a kubernetes secret
5. only worked with password and username in plain text not base64
6. Throws an error is no commonName is set, but common name is deprecated by certmanager and not generated when using annotations in ingress resources
