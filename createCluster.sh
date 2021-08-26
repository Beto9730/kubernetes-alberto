#!/bin/bash
rm -rf kind-configuration.yaml
cat <<EOF >> kind-configuration.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://kind-registry:5000"]
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker 
- role: worker
EOF


kind create cluster \
--name k8s-multinode \
--image kindest/node:v1.16.9 \
--config=kind-configuration.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/kind/deploy.yaml

curl http://localhost

docker run -d --restart=unless-stopped -p "5000:5000" --name "kind-registry" registry:2

docker ps --filter "name=kind-registry"

docker network connect "kind" "kind-registry"

kind get nodes --name k8s-multinode

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml


kubectl patch deployment metrics-server -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","args":["--cert-dir=/tmp", "--secure-port=4443","--v=2", "--kubelet-insecure-tls","--kubelet-preferred-address-types=InternalIP"]}]}}}}'

kubectl get pods -n kube-system


kubectl get all --all-namespaces
