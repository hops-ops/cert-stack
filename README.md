# aws-cert-stack

Single-claim install of [cert-manager](https://github.com/cert-manager/cert-manager) onto a target Kubernetes cluster, plus an opt-in AWS PodIdentity granting the cert-manager controller Route53 access for DNS-01 ACME challenges.

For the full DNS+TLS bundle on AWS (also includes ExternalDNS, Route53 hosted zones, and a ClusterIssuer for Let's Encrypt DNS-01), use `aws-external-dns-stack` which embeds cert-manager when `spec.certManager.enabled: true`.

## Usage

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: CertStack
metadata:
  name: certs
  namespace: default
spec:
  clusterName: my-cluster
  region: us-east-1
```

This composes:
- A cert-manager Helm release on the target cluster
- An AWS `PodIdentity` binding the `cert-manager` ServiceAccount to an IAM role with Route53 ChangeResourceRecordSets / ListResourceRecordSets / ListHostedZonesByName / GetChange permissions

Disable the PodIdentity for clusters that only use HTTP-01 or self-signed Issuers:

```yaml
spec:
  clusterName: dev-cluster
  region: us-east-1
  route53:
    enabled: false
```

## Spec Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clusterName` | string | _required_ | Target cluster name; default for `helmProviderConfigRef.name` |
| `region` | string | `us-east-1` | AWS region for the PodIdentity / IAM resources |
| `permissionsBoundaryArn` | string | — | IAM permissions boundary applied to the cert-manager IAM role |
| `rolePrefix` | string | — | Prefix for the cert-manager IAM role name |
| `tags` | object | — | Extra AWS tags on the IAM resources |
| `namespace` | string | `cert-manager` | Namespace for the Helm release |
| `releaseName` | string | `cert-manager` | Helm release name |
| `chartVersion` | string | `v1.19.2` | cert-manager Helm chart version |
| `route53.enabled` | bool | `true` | Compose the PodIdentity for Route53 DNS-01 access |
| `helmProviderConfigRef.name` | string | `clusterName` | Helm ProviderConfig |
| `helmProviderConfigRef.kind` | enum | `ProviderConfig` | `ProviderConfig` or `ClusterProviderConfig` |
| `kubernetesProviderConfigRef.name` | string | `clusterName` | Kubernetes ProviderConfig (used by PodIdentity to bind on the cluster) |
| `awsProviderConfigRef.name` | string | `default` | AWS ProviderConfig (used by PodIdentity for IAM provisioning) |
| `values` | object | — | Helm values merged with chart defaults |
| `overrideAllValues` | object | — | Helm values that replace all defaults |
| `managementPolicies` | string[] | `["*"]` | Crossplane management policies |
| `labels` | object | — | Custom labels merged with defaults |

## Composed Resources

| Resource | Kind | When |
|---|---|---|
| `<releaseName>` | `helm.m.crossplane.io/Release` | always |
| `<name>-cm` | `aws.hops.ops.com.ai/PodIdentity` | `route53.enabled: true` (default) |
| Usage | `protection.crossplane.io/Usage` | when both Ready (PodIdentity protected from deletion until Helm release is gone) |

## Dependencies

| Kind | Package | Version |
|---|---|---|
| Function | `crossplane-contrib/function-auto-ready` | `>=v0.6.3` |
| Provider | `crossplane-contrib/provider-helm` | `>=v1` |
| Provider | `crossplane-contrib/provider-kubernetes` | `>=v1` |
| Configuration | `hops-ops/aws-pod-identity` | `>=v0.10.0` |

## Development

```bash
make render             # Render all examples
make validate           # Validate against Crossplane schemas
make build              # Build the package
```

## License

Apache-2.0
