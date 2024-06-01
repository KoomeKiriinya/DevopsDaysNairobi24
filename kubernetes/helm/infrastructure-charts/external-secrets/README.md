## External-Secrets


### Install External-Secrets

```shell
kubectl create ns external-secrets
ENVIRONMENT=dev
helm template external-secrets infrastructure-charts/external-secrets/ --values infrastructure-charts/external-secrets/${ENVIRONMENT}.values.yaml -n external-secrets | kubectl apply -f -

```
