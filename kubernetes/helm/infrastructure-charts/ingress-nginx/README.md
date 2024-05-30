## Nginx-ingress


### Install Nginx-ingress

```shell
kubectl create ns nginx-ingress
ENVIRONMENT=dev
helm template nginx-ingress infrastructure-charts/nginx-ingress/ --values infrastructure-charts/nginx-ingress/${ENVIRONMENT}.values.yaml -n nginx-ingress | kubectl apply -f -

```
