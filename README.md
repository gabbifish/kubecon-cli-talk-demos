# Demo code for Kubecon 2020 talk

## Helm (Demo 1): basic abstraction and cross-cutting functionality

Let's deploy something a lot of people have on their clusters: kube-state-metrics exposed via prometheus!
Pulled from prometheus project's helm chart repository on github.'

```bash
cat Chart.yaml
cat requirements.yaml
helm install kube-metrics prometheus-kube-state-metrics
kubectl get deployments
```

## Kustomize (Demo 2):

Some fields can be changed in the values.yaml file. but in cases where you need variance, you don't want to fork the values file and have multiple versions of it! We can control variance using kustomize. In cases where a given value cannot be customized via the values.yaml file, you'll also have to use kustomize to customize your helm chart!

Let's say we want to make the retention period for our prometheus metrics variable depending on whether we're deploying to a staging vs production cluster. After all, we don't need to retain staging metrics for that long, while we might want to keep production metrics around for longer.

1. ```kubectl get deployments```
1. get prom server, grep over "retention" to show retention value
1. show kustomize and patch files in kustomize/overlays directory
1. then show kustomize script

```bash
DEPLOY_ENV=staging helm install kube-metrics prometheus-kube-state-metrics --post-renderer kustomize/kustomize
kubectl get deployment kube-metrics-prometheus-server -o yaml | grep tsdb
```

## Cuelang (Demo 3):

Walk through kube.cue, explain parts of it

Talk about definition, where expected types for values are defined
Talk about structs, which are expanded as part of a definition

```bash
cue eval ./...
cue export --out yaml
```

Show error catching--if I replace replica count with a string, it will get rejected!

## Pulumi (Demo 4):

This is simple... just go over example code and verbally state pulumi command
Explain it works like an installer
Can generate YAML from it but this isn't supported from Go at the moment.

## KPT (Demo 5):

**TODO**


## Example deployment used throughout demos:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    meta.helm.sh/release-name: kube-metrics
    meta.helm.sh/release-namespace: default
  generation: 1
  labels:
    app: prometheus
    app.kubernetes.io/managed-by: Helm
    chart: prometheus-11.16.2
    component: server
    environment: staging
    heritage: Helm
    release: kube-metrics
  name: kube-metrics-prometheus-server
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: prometheus
      component: server
      release: kube-metrics
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: prometheus
    spec:
      containers:
      - args:
        - --storage.tsdb.retention.time=15d
        - --config.file=/etc/config/prometheus.yml
        - --storage.tsdb.path=/data
        - --web.console.libraries=/etc/prometheus/console_libraries
        - --web.console.templates=/etc/prometheus/consoles
        - --web.enable-lifecycle
        image: prom/prometheus:v2.21.0
        imagePullPolicy: IfNotPresent
```