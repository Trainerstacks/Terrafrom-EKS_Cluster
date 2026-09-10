# RBAC 

RBAC YAML configuration for the `jenkins` ServiceAccount, Role, RoleBinding, ClusterRole & ClusterRoleBinding to ensure the ServiceAccount can create all the resources in your YAML file, including dynamic provisioning with StorageClasses and PersistentVolumes.

------

### **1. ServiceAccount**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: webapps
  labels:
    app: jenkins
```

**Purpose**: Creates a dedicated service account for Jenkins to authenticate and authorize with the Kubernetes API server. This account is used for all API calls made by Jenkins within the cluster.

---

### **2. Role**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-role
  namespace: webapps
  labels:
    app: jenkins
rules:
  # Permissions for core API resources
  - apiGroups: [""]
    resources:
      - secrets
      - configmaps
      - persistentvolumeclaims
      - services
      - pods
      - pods/logs
      - pods/exec
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Permissions for apps API group
  - apiGroups: ["apps"]
    resources:
      - deployments
      - deployments/scale
      - replicasets
      - replicasets/scale
      - statefulsets
      - statefulsets/scale
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Permissions for networking API group
  - apiGroups: ["networking.k8s.io"]
    resources:
      - ingresses
      - networkpolicies
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Permissions for autoscaling API group
  - apiGroups: ["autoscaling"]
    resources:
      - horizontalpodautoscalers
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Permissions for batch jobs
  - apiGroups: ["batch"]
    resources:
      - jobs
      - cronjobs
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Event creation for CI/CD tracking
  - apiGroups: [""]
    resources:
      - events
    verbs: ["create", "patch"]
```

**Scope**: Namespace-specific (webapps namespace only)

**Permissions Granted**:
- **Secrets & ConfigMaps**: Store and manage sensitive data and application configuration
- **Pods**: Deploy, monitor, and manage containerized applications; access logs and execute commands
- **Deployments & ReplicaSets**: Manage application replicas and scaling
- **Services & Ingresses**: Expose applications and manage traffic routing
- **StatefulSets**: Manage stateful applications with persistent storage
- **PersistentVolumeClaims**: Provision storage for applications
- **HPA**: Manage auto-scaling policies
- **Jobs & CronJobs**: Execute batch operations and scheduled tasks
- **Events**: Record significant cluster events

---

### **3. RoleBinding**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-rolebinding
  namespace: webapps
  labels:
    app: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins-role
subjects:
  - kind: ServiceAccount
    name: jenkins
    namespace: webapps
```

**Purpose**: Links the `jenkins-role` to the `jenkins` ServiceAccount in the `webapps` namespace. This binding enables Jenkins to use all permissions defined in the Role.

**Scope**: Namespace-specific binding (only applies to webapps namespace)

---

### **4. ClusterRole**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-cluster-role
  labels:
    app: jenkins
rules:
  # Permissions for persistentvolumes (cluster-wide)
  - apiGroups: [""]
    resources:
      - persistentvolumes
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Permissions for storageclasses (cluster-wide)
  - apiGroups: ["storage.k8s.io"]
    resources:
      - storageclasses
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Permissions for volume attachments
  - apiGroups: ["storage.k8s.io"]
    resources:
      - volumeattachments
    verbs: ["get", "list", "watch"]

  # Permissions for ClusterIssuer (cert-manager)
  - apiGroups: ["cert-manager.io"]
    resources:
      - clusterissuers
      - certificates
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Namespace inspection
  - apiGroups: [""]
    resources:
      - namespaces
    verbs: ["get", "list", "watch"]

  # RBAC inspection (for validation)
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources:
      - clusterroles
      - clusterrolebindings
    verbs: ["get", "list", "watch"]
```

**Scope**: Cluster-wide (affects all namespaces)

**Permissions Granted**:
- **PersistentVolumes**: Manage storage across the entire cluster for dynamic provisioning
- **StorageClasses**: Create and manage storage class definitions for different storage backends
- **VolumeAttachments**: Track volume lifecycle and attachment status
- **ClusterIssuers**: Manage TLS certificates using cert-manager at cluster level
- **Namespaces**: Inspect all namespaces for deployment purposes
- **RBAC Resources**: View RBAC configurations for validation and debugging

---

### **5. ClusterRoleBinding**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-cluster-rolebinding
  labels:
    app: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins-cluster-role
subjects:
  - kind: ServiceAccount
    name: jenkins
    namespace: webapps
```

**Purpose**: Binds the `jenkins-cluster-role` to the `jenkins` ServiceAccount for cluster-wide operations. This allows Jenkins to perform cluster-level tasks from within the webapps namespace.

**Scope**: Cluster-wide binding

---

### **Explanation of Permissions**

| Component | Scope | Purpose |
|-----------|-------|---------|
| **ServiceAccount** | Namespace | Authentication identity for Jenkins in Kubernetes |
| **Role** | Namespace | Namespace-scoped permissions for deployment operations |
| **RoleBinding** | Namespace | Grants Role permissions to ServiceAccount |
| **ClusterRole** | Cluster | Cluster-wide permissions for storage and certificates |
| **ClusterRoleBinding** | Cluster | Grants ClusterRole permissions to ServiceAccount |

---

### **How to Apply the YAML Files**

#### **Method 1: Apply Individual Files (Recommended for understanding)**

1. Save each YAML snippet as separate files:
   ```
   serviceaccount.yaml
   role.yaml
   rolebinding.yaml
   clusterrole.yaml
   clusterrolebinding.yaml
   ```

2. Apply them in order:
   ```bash
   # Create namespace first
   kubectl create namespace webapps

   # Apply RBAC components
   kubectl apply -f serviceaccount.yaml
   kubectl apply -f role.yaml
   kubectl apply -f rolebinding.yaml
   kubectl apply -f clusterrole.yaml
   kubectl apply -f clusterrolebinding.yaml
   ```

#### **Method 2: Apply All at Once**

Combine all YAML files separated by `---`:

```bash
kubectl create namespace webapps

# Apply all files
kubectl apply -f serviceaccount.yaml -f role.yaml -f rolebinding.yaml -f clusterrole.yaml -f clusterrolebinding.yaml
```

---

### **Verification - Verify the ServiceAccount has the expected permissions**

```bash
# Check if ServiceAccount exists
kubectl get sa jenkins -n webapps
kubectl describe sa jenkins -n webapps

# Verify Role and RoleBinding
kubectl get role jenkins-role -n webapps
kubectl get rolebinding jenkins-rolebinding -n webapps

# Verify ClusterRole and ClusterRoleBinding
kubectl get clusterrole jenkins-cluster-role
kubectl get clusterrolebinding jenkins-cluster-rolebinding

# Test specific permissions
kubectl auth can-i create secrets --as=system:serviceaccount:webapps:jenkins -n webapps
kubectl auth can-i create storageclasses --as=system:serviceaccount:webapps:jenkins
kubectl auth can-i create persistentvolumes --as=system:serviceaccount:webapps:jenkins
kubectl auth can-i create deployments --as=system:serviceaccount:webapps:jenkins -n webapps
kubectl auth can-i get pods --as=system:serviceaccount:webapps:jenkins -n webapps
```

**Expected Output**: `yes` for all permission checks

---

### **Generate Token using Service Account in the Namespace**

#### **Get Token (Quick Method)**

```bash
# List all secrets in webapps namespace
kubectl get secret -n webapps

# Extract token from secret
kubectl get secret <SECRET_NAME> -n webapps -o jsonpath='{.data.token}' | base64 -d
```

#### **Create Non-Expiring Token (Kubernetes 1.24+)**

```bash
# Create a secret for service account token
kubectl apply -f - << EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-token-secret
  namespace: webapps
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF

# Get the token
kubectl get secret jenkins-token-secret -n webapps -o jsonpath='{.data.token}' | base64 -d
```

#### **One-Liner to Get Token**

```bash
kubectl get secret $(kubectl get secret -n webapps -o jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="jenkins")].metadata.name}') -n webapps -o jsonpath='{.data.token}' | base64 -d
```

---

### **Permission Matrix**

| Resource | Namespace | Cluster | Read | Write | Admin |
|----------|-----------|---------|------|-------|-------|
| Pods | ✅ | ❌ | ✅ | ✅ | ✅ |
| Deployments | ✅ | ❌ | ✅ | ✅ | ✅ |
| Secrets | ✅ | ❌ | ✅ | ✅ | ✅ |
| PVC | ✅ | ❌ | ✅ | ✅ | ✅ |
| Ingresses | ✅ | ❌ | ✅ | ✅ | ✅ |
| PersistentVolumes | ❌ | ✅ | ✅ | ✅ | ✅ |
| StorageClasses | ❌ | ✅ | ✅ | ✅ | ✅ |
| ClusterIssuers | ❌ | ✅ | ✅ | ✅ | ✅ |

---

### **Troubleshooting**

**Problem**: Permission denied when creating resources  
**Solution**: Verify RoleBinding and ClusterRoleBinding are applied
```bash
kubectl get rolebinding jenkins-rolebinding -n webapps
kubectl get clusterrolebinding jenkins-cluster-rolebinding
```

**Problem**: ServiceAccount token not found  
**Solution**: Create the secret manually (Kubernetes 1.24+)
```bash
kubectl apply -f - << EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-token-secret
  namespace: webapps
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF
```

**Problem**: Can't access other namespaces  
**Solution**: This is expected - Role is namespace-scoped. Create additional RoleBindings in other namespaces if needed.

---

### **Reference Documentation**

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [Create Token](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)

---

**Kubernetes Version**: 1.24+
