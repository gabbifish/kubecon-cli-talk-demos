package main

import (
	"fmt"

	appsv1 "github.com/pulumi/pulumi-kubernetes/sdk/v2/go/kubernetes/apps/v1"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v2/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v2/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v2/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v2/go/pulumi/config"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Initialize config
		conf := config.New(ctx, "")

		prometheusLabels := pulumi.StringMap{
			"app": pulumi.String("metrics"),
		}

		// Indicates if this prometheus deploy is for a staging cluster or production cluster
		isStaging := conf.GetBool("staging")

		// Values conditionally set depending on target cluster type; default is production.
		replicas := pulumi.Int(3)
		retentionDays := 30

		if isStaging {
			replicas = pulumi.Int(1)
			retentionDays = 7
		}

		_, err := appsv1.NewDeployment(ctx, "prometheus-server", &appsv1.DeploymentArgs{
			Metadata: &metav1.ObjectMetaArgs{
				Labels: prometheusLabels,
			},
			Spec: appsv1.DeploymentSpecArgs{
				Selector: &metav1.LabelSelectorArgs{
					MatchLabels: prometheusLabels,
				},
				Replicas: replicas,
				Template: &corev1.PodTemplateSpecArgs{
					Metadata: &metav1.ObjectMetaArgs{
						Labels: prometheusLabels,
					},
					Spec: &corev1.PodSpecArgs{
						Containers: corev1.ContainerArray{
							corev1.ContainerArgs{
								Name:            pulumi.String("prometheus-server"),
								Image:           pulumi.String("prom/prometheus:v2.21.0"),
								ImagePullPolicy: pulumi.String("IfNotPresent"),
								Args: pulumi.StringArray{
									pulumi.String(fmt.Sprintf("--storage.tsdb.retention.time=%dd", retentionDays)),
									pulumi.String("--config.file=/etc/config/prometheus.yml"),
									pulumi.String("--storage.tsdb.path=/data"),
									pulumi.String("--web.console.libraries=/etc/prometheus/console_libraries"),
									pulumi.String("--web.console.templates=/etc/prometheus/consoles"),
									pulumi.String("--web.enable-lifecycle}"),
								},
							}},
					},
				},
			},
		})
		return err
	})
}
