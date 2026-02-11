# The Kubernetes Book

## Chapter 4 - Pods, workin' with 'em

### Multi-pod containers

Patterns:

init containers := run in same pod as app containers; start & complete before main app

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: initpod
  labels:
    app: initializer
spec:
  initContainers:
  - name: init-ctr
    image: busybox:1.28.4
    command: ['sh', '-c', 'until nslookup k8sbook; do echo waiting for k8sbook service;\
              sleep 1; done; echo Service found!']
  containers:
    - name: web-ctr
      image: nigelpoulton/web-app:1.0
      ports:
        - containerPort: 8080
```

**While the initContainers are running, Pod's `spec.status1` is ************PENDING******* ***

sidecar containers := adds functionality to app

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: git-sync
  labels:
    app: sidecar
spec:
  initContainers:                     
  - name: ctr-sync                    ---┐  
    restartPolicy: Always                |      <<---- Setting to "Always" makes this a sidecar
    image: k8s.gcr.io/git-sync:v3.1.6    | 
    volumeMounts:                        | 
    - name: html                         | S
      mountPath: /tmp/git                | i
    env:                                 | d
    - name: GIT_SYNC_REPO                | e
      value: https://github.com...       | c
    - name: GIT_SYNC_BRANCH              | a
      value: master                      | r
    - name: GIT_SYNC_DEPTH               | 
      value: "1"                         | 
    - name: GIT_SYNC_DEST                | 
      value: "html"                   ---┘ 
  containers:
  - name: ctr-web                     ---┐ 
    image: nginx                         | A
    volumeMounts:                        | p 
    - name: html                         | p
      mountPath: /usr/share/nginx/    ---┘
  volumes:
  - name: html
    emptyDir: {}
```

**Note:**
