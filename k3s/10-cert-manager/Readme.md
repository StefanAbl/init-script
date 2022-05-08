# Cert-Manager

Install Cert-Manager and FreeIPA issuer to automatically request certificates from FreeIPA.

## Prerequisites
- The kubernetes workers running the controller for the issuing system must be joined to the FreeIPA domain, for the certificate of the FreeIPA server to be recognized

## Installation
Installation of Cert-Manager and the FreeIPA issuer is automated using an Ansible Playbook. However first a service user has to be created in FreeIPA with the permissions detailed in [minimalPermissions.md](minimalPermissions.md). The username and password should be provided to the Playbook in the variables `k3s.ipa_service_user.user/password`.

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
