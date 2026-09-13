# cert-stack

Single-claim install of [cert-manager](https://github.com/cert-manager/cert-manager) onto a target Kubernetes cluster.

Cloud-neutral. DNS-01 plumbing lives in the corresponding DNS stack:
- [`aws-dnsstack`](https://github.com/hops-ops/aws-dns-stack) — composes the Route53 PodIdentity for cert-manager's DNS-01 solver, plus the Let's Encrypt ClusterIssuer.
- [`cloudflare-dnsstack`](https://github.com/hops-ops/cloudflare-dns-stack) — wires the Cloudflare API token Secret consumed by cert-manager's Cloudflare DNS-01 solver, plus the Let's Encrypt ClusterIssuer.

## Usage

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: CertStack
metadata:
  name: certs
  namespace: default
spec:
  clusterName: my-cluster
```

This composes:
- A cert-manager Helm release on the target cluster

## Spec Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clusterName` | string | _required_ | Target cluster name; default for `helmProviderConfigRef.name` |
| `namespace` | string | `cert-manager` | Namespace for the Helm release |
| `releaseName` | string | `cert-manager` | Helm release name |
| `chartVersion` | string | `v1.19.2` | cert-manager Helm chart version |
| `helmProviderConfigRef.name` | string | `clusterName` | Helm ProviderConfig |
| `helmProviderConfigRef.kind` | enum | `ProviderConfig` | `ProviderConfig` or `ClusterProviderConfig` |
| `values` | object | — | Helm values merged with chart defaults |
| `internalCA.enabled` | bool | `false` | Compose a cluster-internal CA and `ClusterIssuer` (`internal-ca`) for in-cluster HTTPS (`*.svc.cluster.local`). Let's Encrypt stays in the DNS stacks. |
| `internalCA.clusterIssuerName` | string | `internal-ca` | Name leaf Certificates should `issuerRef`. |
| `internalCA.secretName` | string | same as issuer | CA Secret in the cert-manager Helm namespace (`ca.crt`). ClusterIssuer looks up that secret in cert-manager's cluster-resource-namespace; this stack sets `--cluster-resource-namespace` to the same Helm `namespace`. |
| `overrideAllValues` | object | — | Helm values that replace all defaults |
| `managementPolicies` | string[] | `["*"]` | Crossplane management policies |
| `labels` | object | — | Custom labels merged with defaults |

## Composed Resources

| Resource | Kind |
|---|---|
| `<releaseName>` | `helm.m.crossplane.io/Release` |
| `internal-ca-bootstrap` (if `internalCA.enabled`) | `ClusterIssuer` (selfSigned) |
| CA `Certificate` + `ClusterIssuer` (if enabled) | cert-manager CA for in-cluster TLS |
| `Usage`s (if enabled) | Delete CA ClusterIssuer → CA cert → bootstrap → Helm |

## Dependencies

| Kind | Package | Version |
|---|---|---|
| Function | `crossplane-contrib/function-auto-ready` | `^v0` |
| Provider | `crossplane-contrib/provider-helm` | `^v1` |

## Development

```bash
make render             # Render all examples
make validate           # Validate against Crossplane schemas
make build              # Build the package
```

## License

Apache-2.0
