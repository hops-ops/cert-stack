### What's changed in v0.3.0

* feat: Burstable resource defaults for cert-manager (controller + cainjector + webhook) (by @patrickleet)

  All three pods shipped as BestEffort by default; cainjector observed at
  163Mi on pat-local. Sized for a small-to-medium cluster; override via
  spec.values for larger fleets.

  Implements [[tasks/cluster-wide-resource-right-sizing-p95-observation]] tier-1 #4

* :  (by @patrickleet)

* feat: Burstable resource defaults for cert-manager (controller + cainjector + webhook) (by @patrickleet)

  All three pods shipped as BestEffort by default; cainjector observed at
  163Mi on pat-local. Sized for a small-to-medium cluster; override via
  spec.values for larger fleets.

  Verified on pat-local: new pods cert-manager-78bd57b8b5,
  cert-manager-cainjector-7f57f5d8f, cert-manager-webhook-55db5974ff
  transitioned to Burstable QoS after install (old BestEffort pods
  draining).

  Implements [[tasks/cluster-wide-resource-right-sizing-p95-observation]] tier-1 #4


See full diff: [v0.2.0...v0.3.0](https://github.com/hops-ops/cert-stack/compare/v0.2.0...v0.3.0)
