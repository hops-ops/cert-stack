# cert-manager-stack

Single-claim install of [cert-manager](https://github.com/cert-manager/cert-manager) onto a target Kubernetes cluster.

Composes one Helm release; no AWS dependencies. Use this when you need cert-manager (CRDs + controller) but not Route53 DNS-01 ClusterIssuers or ExternalDNS.

For the full DNS+TLS bundle on AWS (Route53 hosted zones, ExternalDNS, DNS-01 ClusterIssuer, plus optional embedded cert-manager), use `aws-external-dns-stack`.

## Usage

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: CertManagerStack
metadata:
  name: cert-manager
  namespace: default
spec:
  clusterName: my-cluster
```

## Spec Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clusterName` | string | _required_ | Target cluster name; default for `helmProviderConfigRef.name` |
| `namespace` | string | `cert-manager` | Namespace for the Helm release |
| `releaseName` | string | `cert-manager` | Helm release name |
| `chartVersion` | string | `v1.19.2` | cert-manager Helm chart version |
| `helmProviderConfigRef.name` | string | `clusterName` | Helm ProviderConfig name |
| `helmProviderConfigRef.kind` | enum | `ProviderConfig` | `ProviderConfig` or `ClusterProviderConfig` |
| `values` | object | — | Helm values merged with chart defaults |
| `overrideAllValues` | object | — | Helm values that replace all defaults entirely |
| `managementPolicies` | string[] | `["*"]` | Crossplane management policies |
| `labels` | object | — | Custom labels merged with defaults |

## Composed Resources

| Resource | Kind | Purpose |
|---|---|---|
| `cert-manager` | `helm.m.crossplane.io/Release` | cert-manager Helm release |

## Dependencies

| Kind | Package | Version |
|---|---|---|
| Function | `crossplane-contrib/function-auto-ready` | `>=v0.6.3` |
| Provider | `crossplane-contrib/provider-helm` | `>=v1` |

## Development

```bash
make render             # Render all examples
make validate           # Validate against Crossplane schemas
make build              # Build the package
```

## License

Apache-2.0
