{{/*
Expand the name of the chart.
*/}}
{{- define "nginx-website-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified name.
Priority: fullnameOverride > Release.Name + Chart.Name
Truncate at 63 chars due to DNS naming limits.
*/}}
{{- define "nginx-website-chart.fullname" -}}
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

{{/*
Chart name and version for labels.
Example: nginx-website-chart-1.0.0
*/}}
{{- define "nginx-website-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels (recommended by Kubernetes)
*/}}
{{- define "nginx-website-chart.labels" -}}
helm.sh/chart: {{ include "nginx-website-chart.chart" . }}
app.kubernetes.io/name: {{ include "nginx-website-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "nginx-website-chart.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels (must match between Deployment and Service)
*/}}
{{- define "nginx-website-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nginx-website-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}