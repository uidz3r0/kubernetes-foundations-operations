# W5D2 – Helm Templates & Values

## Objectives

- Understand Helm template syntax
- Use `.Values`
- Use built-in objects
- Override values files
- Use conditionals
- Use loops
- Render templates locally

---

## Lab 1 – Inspect Generated Templates

```bash
cd simplechart

helm template demo .
```

Observe:

- Deployment
- Service
- ServiceAccount

---

## Lab 2 – Override Values

Create:

```yaml
replicaCount: 3
```

Run:

```bash
helm template demo . -f ../yaml/simple-values.yaml
```

Observe the replicas value.

---

## Lab 3 – Multiple Values Files

```bash
helm template demo . \
    -f values.yaml \
    -f ../yaml/production-values.yaml
```

Observe:

- image tag
- replica count

---

## Lab 4 – Add Custom Value

Edit values.yaml:

```yaml
environment: dev
```

Edit deployment template:

```yaml
env:
  - name: ENVIRONMENT
    value: "{{ .Values.environment }}"
```

Render:

```bash
helm template demo .
```

---

## Lab 5 – Conditional Logic

Add:

```yaml
ingress:
  enabled: false
```

Template:

```gotemplate
{{ if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{ end }}
```

Enable:

```yaml
ingress:
  enabled: true
```

Render again.

---

## Lab 6 – Loops

Values:

```yaml
ports:
  - 80
  - 8080
```

Template:

```gotemplate
{{ range .Values.ports }}
- containerPort: {{ . }}
{{ end }}
```

---

## Challenge

Create:

- dev values file
- prod values file

Requirements:

- dev replicas = 1
- prod replicas = 3
- different image tags

Render both:

```bash
helm template demo . -f values-dev.yaml
helm template demo . -f values-prod.yaml
```