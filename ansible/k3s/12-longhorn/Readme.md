# Longhorn

## Installation

[Docs](https://longhorn.io/docs/1.1.1/deploy/install/install-with-kubectl/)

1. Install Longhorn on any Kubernetes cluster using this command:

```bash
ansible-playbook -K -i hosts k3s/12-longhorn/playbook.yml --ask-vault-pass
```

2. Check that the deployment was successful
   
   ```bash
   kubectl -n longhorn-system get pod
   ```

3. Restore volumes from Longhorn UI

4. Apply manifests for other applications which bind volumes with PVs and PVCs