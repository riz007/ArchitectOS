# Kubernetes Architecture

## Preferred Stack

- Kubernetes 1.28+
- Helm 3 for packaging
- Kustomize for environment overlays
- cert-manager for TLS
- External Secrets Operator or Sealed Secrets
- Prometheus + Grafana for observability
- NGINX Ingress Controller

## Recommended Anti-Patterns to Avoid

- Running containers as root
- Using `latest` image tag
- Deploying without resource requests/limits
- Missing liveness/readiness probes
- Storing secrets in ConfigMaps
- Using `hostNetwork: true` or `hostPID: true`
- Single-replica deployments in production

---

## Namespace Strategy

```yaml
# Separate namespaces by environment and team
namespaces:
  - production
  - staging
  - development
  - monitoring
  - ingress-nginx
  - cert-manager
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    team: platform
```

---

## Deployment Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: production
  labels:
    app: api
    version: "2.4.0"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Zero-downtime rolling updates
  template:
    metadata:
      labels:
        app: api
        version: "2.4.0"
    spec:
      serviceAccountName: api-service-account

      # Spread pods across nodes for resilience
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app: api

      containers:
        - name: api
          image: registry.example.com/api:${GIT_SHA}  # Never use :latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
              name: http

          # Environment from ConfigMap and Secrets
          envFrom:
            - configMapRef:
                name: api-config
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: api-secrets
                  key: database-url
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: api-secrets
                  key: jwt-secret

          # Resource constraints — required for all pods
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"

          # Liveness: restart if the pod is stuck
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 3
            timeoutSeconds: 5

          # Readiness: don't send traffic until ready
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
            timeoutSeconds: 3

          # Startup: extra time for slow-starting apps
          startupProbe:
            httpGet:
              path: /health
              port: 3000
            failureThreshold: 30
            periodSeconds: 2

          # Security hardening
          securityContext:
            runAsNonRoot: true
            runAsUser: 1001
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]

          # Writable temp dir for apps that need it
          volumeMounts:
            - name: tmp
              mountPath: /tmp

      volumes:
        - name: tmp
          emptyDir: {}

      # Graceful shutdown
      terminationGracePeriodSeconds: 60
```

---

## Service and Ingress

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: production
spec:
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
      name: http
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  name: http
```

---

## Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Don't scale down too fast
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
        - type: Pods
          value: 4
          periodSeconds: 60
```

---

## Pod Disruption Budget

Ensure minimum availability during node maintenance:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-pdb
  namespace: production
spec:
  minAvailable: 2  # or maxUnavailable: 1
  selector:
    matchLabels:
      app: api
```

---

## ConfigMap and Secrets Pattern

```yaml
# Non-sensitive configuration in ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
  namespace: production
data:
  NODE_ENV: "production"
  PORT: "3000"
  LOG_LEVEL: "info"
  CORS_ORIGINS: "https://app.example.com"
  REDIS_TTL: "300"

---
# Sensitive values — use External Secrets Operator in production
# This example shows the Secret structure (values come from a secret manager)
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-parameter-store
    kind: ClusterSecretStore
  target:
    name: api-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-url
      remoteRef:
        key: /production/api/database-url
    - secretKey: jwt-secret
      remoteRef:
        key: /production/api/jwt-secret
```

---

## Kustomize Structure

```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── hpa.yaml
│   ├── pdb.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── staging/
│   │   ├── patch-replicas.yaml   # replicas: 1
│   │   ├── patch-resources.yaml  # smaller resource limits
│   │   └── kustomization.yaml
│   └── production/
│       ├── patch-replicas.yaml   # replicas: 3
│       ├── patch-ingress.yaml    # production domain
│       └── kustomization.yaml
```

```yaml
# k8s/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
  - hpa.yaml
  - pdb.yaml
```

---

## Health Check Endpoints Implementation

Every service must implement these endpoints:

```typescript
// /health — liveness check (is the process alive?)
@Get('health')
health() {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION,
  }
}

// /ready — readiness check (can the pod serve traffic?)
@Get('ready')
async ready() {
  try {
    await this.db.query('SELECT 1')
    await this.cache.ping()
    return { status: 'ready' }
  } catch (error) {
    throw new ServiceUnavailableException({
      status: 'not ready',
      reason: error.message,
    })
  }
}

// /metrics — Prometheus metrics
@Get('metrics')
async metrics(@Res() res: Response) {
  res.set('Content-Type', register.contentType)
  res.send(await register.metrics())
}
```
