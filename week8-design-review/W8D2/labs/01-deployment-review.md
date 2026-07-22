# Lab 1 — Deployment Review

Start with a realistic Deployment and treat it as a design discussion, not just a YAML example.

The key question is: why would an engineer choose this configuration for a production workload?

```yaml
apiVersion: apps/v1

kind: Deployment

metadata:
  name: demo-app

spec:
  replicas: 3

  strategy:
    type: RollingUpdate

    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1

  selector:
    matchLabels:
      app: demo

  template:

    metadata:
      labels:
        app: demo

    spec:

      containers:

      - name: nginx

        image: nginx:stable

        ports:
        - containerPort: 80

        resources:

          requests:
            cpu: 100m
            memory: 128Mi

          limits:
            cpu: 500m
            memory: 512Mi

        readinessProbe:

          httpGet:
            path: /
            port: 80

        livenessProbe:

          httpGet:
            path: /
            port: 80

        startupProbe:

          httpGet:
            path: /
            port: 80
```

Then review every field.

| Field          | Why?                               |
| -------------- | ---------------------------------- |
| replicas       | High availability                  |
| RollingUpdate  | No downtime                        |
| maxUnavailable | Keep enough Pods alive             |
| maxSurge       | Create new Pods first              |
| selector       | Must match labels                  |
| requests       | Scheduler decision                 |
| limits         | Prevent resource abuse             |
| readinessProbe | Remove unhealthy Pods from Service |
| livenessProbe  | Restart stuck containers           |
| startupProbe   | Prevent premature restarts         |
