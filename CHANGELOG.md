### What's changed in v0.1.0

* feat: cert-manager-stack — standalone cert-manager install (by @patrickleet)

  Single-claim Crossplane Configuration that installs cert-manager (CRDs +
  controller) on a target Kubernetes cluster as one Helm release.

  No AWS dependencies. For DNS-01 / Route53 ClusterIssuers + ExternalDNS,
  use aws-external-dns-stack instead (or alongside, depending on whether
  its certManager.enabled flag is set).

  Use cases:
  - Clusters that need cert-manager but not Route53 (e.g. for the
    cnpg-i-scale-to-zero plugin's gRPC self-signed Issuer + Certificates)
  - Splitting concerns: cert-manager-stack handles cert-manager;
    external-dns-stack handles DNS automation

  Implements [[tasks/cert-manager-stack]]

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>

* refactor: rename CertManagerStack → CertsStack; move to xrs/stacks/aws/certs (by @patrickleet)

  - Group: hops.ops.com.ai → aws.hops.ops.com.ai (this is an AWS-namespaced
    stack — composes a PodIdentity for Route53)
  - Kind: CertManagerStack → CertsStack; plural certmanagerstacks →
    certsstacks
  - Configuration package: cert-manager-stack → aws-certs-stack
  - Spec flattened: dropped the spec.aws wrapper. Top-level fields are
    region, permissionsBoundaryArn, rolePrefix, tags, awsProviderConfigRef,
    kubernetesProviderConfigRef
  - New: spec.route53.enabled (default true) gates the PodIdentity
    composition. Disable for clusters using only HTTP-01 or self-signed
    Issuers.
  - Lifted PodIdentity composition pattern from xrs/stacks/aws/dns —
    cert-manager ServiceAccount bound to an IAM role with the four
    Route53 actions needed for DNS-01 challenges.
  - Default labels/tags now derive from lower(kind) like other stacks
    (hops.ops.com.ai/certsstack key, not hops.ops.com.ai/cert-manager).
  - Configuration depsOn: provider-kubernetes + aws-pod-identity
    Configuration package added.

  Implements [[tasks/cert-manager-stack]]

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>

* rename: CertsStack → CertStack (singular reads better) (by @patrickleet)

  - Kind: CertsStack → CertStack
  - Plural: certsstacks → certstacks
  - XRD metadata.name: certsstacks.aws.hops.ops.com.ai → certstacks.aws.hops.ops.com.ai
  - Configuration package: aws-certs-stack → aws-cert-stack
  - Directory: xrs/stacks/aws/certs/ → xrs/stacks/aws/cert/
  - apis/certsstacks/ → apis/certstacks/
  - examples/certsstacks/ → examples/certstacks/

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>

* feat: cloud-neutral cert-stack — group hops.ops.com.ai, drop AWS coupling (by @patrickleet)

  XRD group: aws.hops.ops.com.ai → hops.ops.com.ai. Stack now installs
  cert-manager via Helm only; cloud-specific DNS-01 plumbing (Route53
  PodIdentity, Cloudflare API token) lives in the corresponding DNS stack.

  - Drop Route53 PodIdentity composition + AWS provider deps
  - Slim XRD to cert-manager Helm essentials (clusterName, namespace,
    releaseName, chartVersion, values, overrideAllValues, helmProviderConfigRef)
  - Tests: unit (test-render) + e2e (e2etest-cert-stack)
  - CI: on-pr, on-push-main, on-version-tagged via unbounded-tech workflows

  Implements [[tasks/cert-manager-stack]]


