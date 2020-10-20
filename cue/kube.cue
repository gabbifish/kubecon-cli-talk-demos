package kube

deployment: production: {
	spec: {
		replicas: 3
		template: {
			metadata: labels: component: "production-metrics"
			spec: containers: [
				{
					args: [
						"storage.tsdb.retention.time=30d",
						"config.file=/etc/config/prometheus.yml",
						"storage.tsdb.path=/data",
						"web.console.libraries=/etc/prometheus/console_libraries",
						"web.console.templates=/etc/prometheus/consoles",
						"web.enable-lifecycle",
					]
				},
			]
		}
	}
}

deployment: staging: {
	spec: {
		replicas: 1
		template: {
			metadata: labels: component: "staging-metrics"
			spec: containers: [
				{
					args: [
						"storage.tsdb.retention.time=7d",
						"config.file=/etc/config/prometheus.yml",
						"storage.tsdb.path=/data",
						"web.console.libraries=/etc/prometheus/console_libraries",
						"web.console.templates=/etc/prometheus/consoles",
						"web.enable-lifecycle",
					]
				},
			]
		}
	}
}

_#retention: "13"

deployment: [ID=_]: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: name: "kube-metrics-prometheus-server"
	spec: {
		// 1 is the default, but we allow any number
		replicas: int
		template: {
			metadata: labels: {
				app:       ID
				component: string
			}
			// we always have one namesake container
			spec: containers: [
				{
					name:            ID
					image:           "prom/prometheus:v2.21.0"
					imagePullPolicy: "IfNotPresent"
				},
			]
		}
	}
}
