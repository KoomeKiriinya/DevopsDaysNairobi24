## Cert-Manager

** Requirements **

- Ensure external-secrets is first installed.

## Install Cert-Manager
```shell
# Create the namespace
$ kubectl create ns cert-manager
```

```shell
# Install CRDs manually. !! Verify VERSION !!
$ kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml
```

```shell
ENVIRONMENT=uat
helm template cert-manager infrastructure-charts/cert-manager/ --values infrastructure-charts/cert-manager/${ENVIRONMENT}.values.yaml -n cert-manager | kubectl apply -f -
