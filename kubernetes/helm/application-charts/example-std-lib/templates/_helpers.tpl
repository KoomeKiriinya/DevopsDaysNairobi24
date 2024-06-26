{{/*
Expand the name of the chart.
*/}}
{{- define "example.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "example.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "example.tag" -}}
{{- $tag := default .Values.image.tag | required "image.tag is not set" }}
{{- printf "%s" $tag }}
{{- end }}

{{- define "example.repository" -}}
{{- $repository :=  .Values.image.repository | required "image.repository is not set" }}
{{- printf "%s" $repository }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "example.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "example.labels" -}}
helm.sh/chart: {{ include "example.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{- define "example.tls_annotations" -}}
{{- if .Values.ingress.tls.enabled }}
cert-manager.io/cluster-issuer: {{ .Values.issuer }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "example.deploymentSelectorLabels" -}}
app.kubernetes.io/name: {{ include "example.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "example.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "example.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
