# Commands to setup TKG

$env:KUBECTL_VSPHERE_PASSWORD="<password>"
kubectl vsphere login --server=<ip address> --vsphere-username=DOMAIN\username --insecure-skip-tls-verify
kubectl config use-context orsted-test
kubectl apply -f .\tkg-cluster-definition.yaml

# Check status
kubectl get nodes
kubectl describe TanzuKubernetesCluster tkgs-v2-cluster-default -n <namespace>

# When done get config
$base64Kubeconfig = kubectl get secret tkgs-v2-cluster-default-kubeconfig -n <namespace> -o=jsonpath='{.data.value}'
$kubeconfig = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Kubeconfig))
$kubeconfig | Out-File -Encoding utf8 tkg-v2-cluster-default-kubeconfig.yaml
$env:KUBECONFIG="tkg-v2-cluster-default-kubeconfig.yaml"
