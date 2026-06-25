# W5D2 Notes – Helm Templating

## Template Syntax

```gotemplate
{{ }}
```

Everything inside braces is evaluated.

---

## Values

```gotemplate
{{ .Values.replicaCount }}
```

Reads:

```yaml
replicaCount: 2
```

---

## Built-in Objects

| Object | Description |
|--------|-------------|
| .Values | values.yaml |
| .Release | release information |
| .Chart | Chart.yaml information |
| .Capabilities | cluster capabilities |

Example:

```gotemplate
{{ .Release.Name }}
```

---

## Pipelines

```gotemplate
{{ .Values.name | quote }}
```

Output:

```yaml
name: "myapp"
```

---

## Conditionals

```gotemplate
{{ if .Values.enabled }}
...
{{ end }}
```

---

## Else

```gotemplate
{{ if .Values.prod }}
Production
{{ else }}
Development
{{ end }}
```

---

## Loops

```gotemplate
{{ range .Values.ports }}
- {{ . }}
{{ end }}
```

---

## Rendering

```bash
helm template demo .
```

No installation occurs.

---

## Debugging

```bash
helm template demo . --debug

helm lint .
```

---

## Values Override Order

Lowest priority:

1. values.yaml

Higher:

2. -f values.yaml

Highest:

3. --set

Example:

```bash
helm install demo . \
    --set replicaCount=5
```

---

## Useful Commands

```bash
helm template demo .

helm lint .

helm install demo .

helm upgrade demo .

helm uninstall demo
```