import models.ai.com.ops.hops.v1alpha1 as stacksv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# ==============================================================================
# Unit tests for CertStack XRD
#
# Philosophy: test YOUR API, not the provider's.
# - render/validate already checks provider schema correctness
# - Tests should verify XRD spec fields produce expected behavior
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: minimal claim renders the cert-manager Helm release.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-cert-manager"
        spec = {
            compositionPath = "apis/certstacks/composition.yaml"
            xrdPath = "apis/certstacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.CertStack {
                metadata.name = "test-certs"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "cert-manager"
                    spec.forProvider = {
                        chart = {
                            name = "cert-manager"
                            repository = "https://charts.jetstack.io"
                            version = "v1.19.2"
                        }
                        namespace = "cert-manager"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: custom labels merge with the stack's defaults.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-labels-merged-with-defaults"
        spec = {
            compositionPath = "apis/certstacks/composition.yaml"
            xrdPath = "apis/certstacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.CertStack {
                metadata.name = "labeled-certs"
                spec = {
                    clusterName = "my-cluster"
                    labels = {team = "platform", environment = "staging"}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "cert-manager"
                        labels = {
                            "hops.ops.com.ai/managed" = "true"
                            "hops.ops.com.ai/certstack" = "labeled-certs"
                            team = "platform"
                            environment = "staging"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: custom chartVersion propagates to the Helm release.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-chart-version-propagates"
        spec = {
            compositionPath = "apis/certstacks/composition.yaml"
            xrdPath = "apis/certstacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.CertStack {
                metadata.name = "version-test"
                spec = {
                    clusterName = "my-cluster"
                    chartVersion = "v1.18.0"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "cert-manager"
                    spec.forProvider.chart.version = "v1.18.0"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: custom namespace propagates to the Helm release.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-namespace-propagates"
        spec = {
            compositionPath = "apis/certstacks/composition.yaml"
            xrdPath = "apis/certstacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.CertStack {
                metadata.name = "ns-test"
                spec = {
                    clusterName = "my-cluster"
                    namespace = "cert-system"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "cert-manager"
                    spec.forProvider.namespace = "cert-system"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 5: overrideAllValues replaces the chart values entirely.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "override-all-values-replaces-defaults"
        spec = {
            compositionPath = "apis/certstacks/composition.yaml"
            xrdPath = "apis/certstacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.CertStack {
                metadata.name = "override-test"
                spec = {
                    clusterName = "my-cluster"
                    overrideAllValues = {
                        crds = {enabled = False}
                        replicaCount = 3
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "cert-manager"
                    spec.forProvider.values = {
                        crds = {enabled = False}
                        replicaCount = 3
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 6: helmProviderConfigRef defaults to clusterName.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "helm-provider-config-defaults-to-cluster-name"
        spec = {
            compositionPath = "apis/certstacks/composition.yaml"
            xrdPath = "apis/certstacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.CertStack {
                metadata.name = "provider-test"
                spec.clusterName = "prod-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "cert-manager"
                    spec.providerConfigRef = {
                        name = "prod-cluster"
                        kind = "ProviderConfig"
                    }
                }
            ]
        }
    }
]

items = _items
