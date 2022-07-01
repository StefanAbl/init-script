# Kubernetes Cluster

## Dependencies on localhost

- [Flux CLI](https://fluxcd.io/docs/installation/)
- SSH key for GitHub
- Kubectl
- [SOPS](https://github.com/mozilla/sops/releases)

## Useful Commands

### Create an Encrypted Secret

- Create the secret as usual and write the secrets in plain text
- Run the following command to encrypt the secret with SOPS

```bash
sops --encrypt --in-place cluster/apps/namespace/secret.yml
```

## Bootstrap Flux on the Cluster

After running the Terraform and ansible commands to create the VMs and install K3s, use the following commands to install Flux.

```bash
OWNER="$(git config --get remote.origin.url | sed 's/.*://g' | sed 's/\/.*git//g' )"
REPO="$(git config --get remote.origin.url | sed 's/.*://g' | sed 's/.git//g' | sed 's/.*\///g' )"
echo "GitHub Repository is $OWNER/$REPO"

flux bootstrap github \
--version=v0.12.1 \
--owner=$OWNER \
--repository=$REPO \
--path=cluster/base \
--personal \
--network-policy=false
```

### Setup Secrets Encryption for Cluster

Based on [Flux Guides](https://fluxcd.io/docs/guides/mozilla-sops/)

```bash
export KEY_NAME="flux"
export KEY_COMMENT="flux secrets"

gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF

gpg --export-secret-keys --armor "${KEY_NAME}" |
kubectl create secret generic sops-gpg \
--namespace=flux-system \
--from-file=sops.asc=/dev/stdin \
--kubeconfig=./kubeconfig.yml

gpg --list-secret-keys "${KEY_NAME}"
```

Get the key fingerprint from the last command above. 
Create the file `.sops.yaml` with the following contents.

```yaml
creation_rules:
  - encrypted_regex: ^(data|stringData)$
    pgp: KEY_FINGERPRINT
```

Also add the following to the Kustomization in the file `gotk-sync.yaml`:

```yaml
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
```

Get the public and private key and back them up with a password manager.

```bash
echo "Private Key"
gpg --export-secret-keys --armor "${KEY_NAME}"
echo "Public Key"
gpg --armor --export "${KEY_NAME}"
```