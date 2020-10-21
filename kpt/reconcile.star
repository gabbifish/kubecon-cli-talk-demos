def reconcile(items):

  server = None

  for resource in items:
    if resource.get("metadata") == None:
      resource["metadata"] = {}
    if resource["metadata"].get("annotations") == None:
      resource["metadata"]["annotations"] = {}
    if resource["metadata"]["annotations"].get("example.com/prometheus") == "kube-metrics-prometheus-server":
      server = resource

  d = {
   "apiVersion": "apps/v1",
   "kind": "Deployment",
   "metadata": {
      "annotations": {
         "deployment.kubernetes.io/revision": "1",
         "meta.helm.sh/release-name": "kube-metrics",
         "meta.helm.sh/release-namespace": "default"
      },
      "generation": 1,
      "labels": {
         "app": "prometheus",
         "app.kubernetes.io/managed-by": "Helm",
         "chart": "prometheus-11.16.2",
         "component": "server",
         "environment": "staging",
         "heritage": "Helm",
         "release": "kube-metrics"
      },
      "name": "kube-metrics-prometheus-server",
      "namespace": "default"
   },
   "spec": {
      "progressDeadlineSeconds": 600,
      "replicas": 1,
      "revisionHistoryLimit": 10,
      "selector": {
         "matchLabels": {
            "app": "prometheus",
            "component": "server",
            "release": "kube-metrics"
         }
      },
      "template": {
         "metadata": {
            "labels": {
               "app": "prometheus"
            }
         },
         "spec": {
            "containers": [
               {
                  "args": [
                     "--storage.tsdb.retention.time=15d",
                     "--config.file=/etc/config/prometheus.yml",
                     "--storage.tsdb.path=/data",
                     "--web.console.libraries=/etc/prometheus/console_libraries",
                     "--web.console.templates=/etc/prometheus/consoles",
                     "--web.enable-lifecycle"
                  ],
                  "image": "prom/prometheus:v2.21.0",
                  "imagePullPolicy": "IfNotPresent"
               }
            ]
         }
      }
   }
}

  if server == None:
    items.append(d)
    return

  items.remove(resource)
  if server.get("spec") != None and len(server["spec"]["template"]["spec"]["containers"]) == 1:
    d["spec"]["template"]["spec"]["containers"][0]["args"][0] = server["spec"]["template"]["spec"]["containers"][0]["args"][0]
  items.append(d)

reconcile(ctx.resource_list["items"])
