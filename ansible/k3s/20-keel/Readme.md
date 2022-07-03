# Keel

[Keel](https://keel.sh/) is a system which helps with updating the image tags of deployments and helm charts.

## Usage

Add annotations to Deployments and STS's.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: wd-ds
  annotations:
      keel.sh/policy: minor     # update policy (available: patch, minor, major, all, force)
      keel.sh/trigger: poll     # enable active repository checking (webhooks and GCR would still work)
      keel.sh/approvals: "1"    # required approvals to update
      keel.sh/match-tag: "true" # only makes a difference when used with 'force' policy, will only update if tag matches :dev->:dev, :prod->:prod 
      keel.sh/pollSchedule: "@every 1m"
spec:

```

Available policies:

- **all**: update whenever there is a version bump or a new prerelease created (ie: `1.0.0` -> `1.0.1-rc1`)
- **major**: update major & minor & patch versions
- **minor**: update only minor & patch versions (ignores major)
- **patch**: update only patch versions (ignores minor and major versions)
- **force**: force update even if tag is not semver, ie: `latest`, optional label: **keel.sh/match-tag=true** which will enforce that only the same tag will trigger force update.
- **glob**: use wildcards to match versions, example: