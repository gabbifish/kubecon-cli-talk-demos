
REM package kube

REM import (
REM 	"encoding/yaml"
REM 	"tool/exec"
REM 	"tool/cli"
REM )

REM command: create: {
REM 	task: kube: exec.Run & {
REM 		cmd:    "kubectl create --dry-run -f -"
REM 		stdin:  yaml.MarshalStream(objects)
REM 		stdout: string
REM 	}

REM 	task: display: cli.Print & {
REM 		text: task.kube.stdout
REM 	}
REM }