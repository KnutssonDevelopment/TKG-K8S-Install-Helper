# Commands to setup TKG

## Setup kubernetes control-plane and workers for the vSphere namespace
```
$env:KUBECTL_VSPHERE_PASSWORD="<password>"
kubectl vsphere login --server=<ip-address> --vsphere-username=<domain>\<username> --insecure-skip-tls-verify
kubectl config use-context test-namespace
kubectl apply -f .\tkg-cluster-definition.yaml
```

# Check status
```
kubectl get nodes
kubectl describe TanzuKubernetesCluster tkgs-v2-cluster-default -n <namespace>
```

# When done get config
```
$base64Kubeconfig   = kubectl get secret tkgs-v2-cluster-default-kubeconfig -n <namespace> -o=jsonpath='{.data.value}'
$kubeconfig         = [ System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Kubeconfig))

$kubeconfig | Out-File -Encoding utf8 tkg-v2-cluster-default-kubeconfig.yaml
$env:KUBECONFIG="tkg-v2-cluster-default-kubeconfig.yaml"
```

## Lower security to be able to deploy containers
```
kubectl apply -f role-binding.yaml
kubectl apply -f cluster-role-binding.yaml
```

## Deploy Hello world Web Service container
```
kubectl create configmap custom-nginx-index --from-file=hello-world-web-content\index.html --from-file=hello-world-web-content\style.css
kubectl apply -f hello-world-deployment.yaml
kubectl apply -f hello-world-service.yaml
```
