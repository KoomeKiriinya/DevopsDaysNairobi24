## Argocd

** Requirements **

- Ensure external-secrets,cert-manager and nginx-ingress are first installed.

- Add argocd secretkey (serversecretkey),adminpassword and ssh privatekey are added to secrets manager
  as referenced in external-secrets


## Install Argocd
```shell
kubectl create ns argocd
ENVIRONMENT=dev
helm template argocd infrastructure-charts/argo-cd/ --values infrastructure-charts/argo-cd/${ENVIRONMENT}.values.yaml -n argocd | kubectl apply -f -

```