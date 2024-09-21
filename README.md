# Amazon Managed Service for Prometheus (AMP) prometheus server deployment using Longhorn CSI
Enabling Amazon Managed Service for Prometheus (AMP) prometheus server on EC2 instances (as EKS worker nodes) without EBS CSI, but using Longhorn CSI instead: https://longhorn.io
Useful for Outposts servers or other instance store EC2 instances type.

Ingestion towards Amazon Managed Service for Prometheus (AMP) workspaces as described here: https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/

All possible values from prometheus upstream are here: https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml

## usage
```
Admin:~/environment/amp $ IAM_PROXY_PROMETHEUS_ROLE_ARN=arn:aws:iam::01234567890:role/EKS-AMP-ServiceAccount-Role
Admin:~/environment/amp $ WORKSPACE_ID=ws-7c0e42fa-672e-408e-9970-f4343ff6233f
Admin:~/environment/amp $ AWS_REGION=us-east-1

Admin:~/environment/amp $ helm install prometheus-for-amp prometheus-community/prometheus -n prometheus -f ./amp_ingest_override_values-storageclass-modify.yaml \--set serviceAccounts.server.annotations."eks\.amazonaws\.com/role-arn"="${IAM_PROXY_PROMETHEUS_ROLE_ARN}" \--set server.remoteWrite[0].url="https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${WORKSPACE_ID}/api/v1/remote_write" \--set server.remoteWrite[0].sigv4.region=${AWS_REGION}
NAME: prometheus-for-amp
LAST DEPLOYED: Fri Aug 30 04:21:18 2024
NAMESPACE: prometheus
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-for-amp-server.prometheus.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus-for-amp" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9090


The Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
prometheus-for-amp-alertmanager.prometheus.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus-for-amp" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been disabled by default since    #####
######            it deprecated after k8s 1.25+. use                        #####
######            (index .Values "prometheus-node-exporter" "rbac"          #####
###### .          "pspEnabled") with (index .Values                         #####
######            "prometheus-node-exporter" "rbac" "pspAnnotations")       #####
######            in case you still need it.                                #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-for-amp-prometheus-pushgateway.prometheus.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/
Admin:~/environment/amp $ 
```

## longhorn pv and pvc created for prometheus
Once you define a storage class with Longhorn, and then insert the storage class name inside the helm override parameter yaml, the PV and PVC will be created automatically
```
Admin:~/environment/amp $ kubectl get pvc -A
NAMESPACE    NAME                                         STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
default      longhorn-pvc                                 Bound         pvc-e8d87a93-ef2d-44a0-9b79-28481853ceb2   10Gi       RWX            longhorn-sc    <unset>                 20d
default      longhorn-pvc3                                Bound         pvc-f48a0bfe-0c90-440e-8cf0-4694413bacee   10Gi       RWX            longhorn-sc    <unset>                 9d
prometheus   storage-prometheus-for-amp-alertmanager-0    Bound         pvc-b6b83151-9f51-459e-a8ae-f376752f6832   2Gi        RWO            longhorn       <unset>                 17m
prometheus   storage-volume-prometheus-for-amp-server-0   Bound         pvc-082458e3-1748-4d92-934d-9e1c4de09e1e   8Gi        RWO            longhorn-sc    <unset>                 17m

Admin:~/environment/amp $ kubectl get pv -A
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-082458e3-1748-4d92-934d-9e1c4de09e1e   8Gi        RWO            Delete           Bound    prometheus/storage-volume-prometheus-for-amp-server-0   longhorn-sc    <unset>                          17m
pvc-b6b83151-9f51-459e-a8ae-f376752f6832   2Gi        RWO            Delete           Bound    prometheus/storage-prometheus-for-amp-alertmanager-0    longhorn       <unset>                          17m
pvc-dee66439-33a0-45a4-9b2e-cd4d8c6f3e2a   10Gi       RWX            Delete           Bound    default/longhorn-pvc2                                   longhorn-sc2   <unset>                          15d
pvc-e8d87a93-ef2d-44a0-9b79-28481853ceb2   10Gi       RWX            Delete           Bound    default/longhorn-pvc                                    longhorn-sc    <unset>                          20d
pvc-f48a0bfe-0c90-440e-8cf0-4694413bacee   10Gi       RWX            Delete           Bound    default/longhorn-pvc3                                   longhorn-sc    <unset>                          9d
Admin:~/environment/amp $ 
```

## pods running
```
Admin:~/environment/amp $ kubectl get po -A
NAMESPACE         NAME                                                         READY   STATUS    RESTARTS        AGE
default           longhorn-iscsi-installation-b4q4k                            1/1     Running   1 (18d ago)     20d
default           longhorn-iscsi-installation-l8zbc                            1/1     Running   0               20d
default           longhorn-iscsi-installation-pflwv                            1/1     Running   0               20d
default           longhorn-iscsi-installation-rzzkr                            1/1     Running   0               20d
default           longhorn-nfs-installation-9f6lx                              1/1     Running   1 (18d ago)     20d
default           longhorn-nfs-installation-j4mkl                              1/1     Running   0               20d
default           longhorn-nfs-installation-jbvbz                              1/1     Running   0               20d
default           longhorn-nfs-installation-xzm2n                              1/1     Running   0               20d
default           longhorn-samplepod                                           1/1     Running   0               20d
default           longhorn-samplepod2                                          1/1     Running   0               15d
default           ubuntu-frr                                                   1/1     Running   0               7d10h
default           ubuntu-netutils                                              1/1     Running   0               10d
default           ubuntu-netutils2                                             1/1     Running   0               8d
kube-system       aws-node-4dq7q                                               2/2     Running   0               20d
kube-system       aws-node-6vktb                                               2/2     Running   0               20d
kube-system       aws-node-d5k2f                                               2/2     Running   2 (18d ago)     20d
kube-system       aws-node-gpf4c                                               2/2     Running   0               20d
kube-system       coredns-54d6f577c6-c2rnh                                     1/1     Running   1 (18d ago)     20d
kube-system       coredns-54d6f577c6-q4t8z                                     1/1     Running   0               20d
kube-system       eks-pod-identity-agent-rkt4j                                 1/1     Running   1 (18d ago)     20d
kube-system       eks-pod-identity-agent-sm9pc                                 1/1     Running   0               20d
kube-system       eks-pod-identity-agent-tgj9n                                 1/1     Running   0               20d
kube-system       eks-pod-identity-agent-xm2n4                                 1/1     Running   0               20d
kube-system       kube-multus-ds-5lt9s                                         1/1     Running   2 (20d ago)     20d
kube-system       kube-multus-ds-6vch5                                         1/1     Running   2 (20d ago)     20d
kube-system       kube-multus-ds-hnbx4                                         1/1     Running   3 (18d ago)     20d
kube-system       kube-multus-ds-wfzxf                                         1/1     Running   2 (20d ago)     20d
kube-system       kube-proxy-96jqm                                             1/1     Running   0               20d
kube-system       kube-proxy-jdzx6                                             1/1     Running   1 (18d ago)     20d
kube-system       kube-proxy-k8btw                                             1/1     Running   0               20d
kube-system       kube-proxy-s7crq                                             1/1     Running   0               20d
kube-system       kube-sriov-device-plugin-amd64-lp2hd                         1/1     Running   0               10d
kube-system       kube-sriov-device-plugin-amd64-slnrq                         1/1     Running   0               10d
kube-system       kube-sriov-device-plugin-amd64-vtllv                         1/1     Running   0               10d
kube-system       kube-sriov-device-plugin-amd64-w8hpm                         1/1     Running   0               10d
longhorn-system   csi-attacher-54946dbcb8-kbjph                                1/1     Running   1 (18d ago)     20d
longhorn-system   csi-attacher-54946dbcb8-sds46                                1/1     Running   5 (4d16h ago)   20d
longhorn-system   csi-attacher-54946dbcb8-zxc9r                                1/1     Running   0               20d
longhorn-system   csi-provisioner-7b64855c94-2wkvb                             1/1     Running   2 (8d ago)      20d
longhorn-system   csi-provisioner-7b64855c94-ngctv                             1/1     Running   4 (4d4h ago)    20d
longhorn-system   csi-provisioner-7b64855c94-zcsbv                             1/1     Running   0               20d
longhorn-system   csi-resizer-8b4b94dcd-b7p7h                                  1/1     Running   3 (8d ago)      20d
longhorn-system   csi-resizer-8b4b94dcd-fs29k                                  1/1     Running   2 (4d16h ago)   20d
longhorn-system   csi-resizer-8b4b94dcd-g9cv6                                  1/1     Running   0               20d
longhorn-system   csi-snapshotter-5847d4c879-7fjhx                             1/1     Running   0               20d
longhorn-system   csi-snapshotter-5847d4c879-clj9l                             1/1     Running   1 (17d ago)     20d
longhorn-system   csi-snapshotter-5847d4c879-tb7r7                             1/1     Running   4 (4d16h ago)   20d
longhorn-system   engine-image-ei-b0369a5d-l4zxr                               1/1     Running   0               20d
longhorn-system   engine-image-ei-b0369a5d-lbzrh                               1/1     Running   1 (18d ago)     20d
longhorn-system   engine-image-ei-b0369a5d-vx8v6                               1/1     Running   0               20d
longhorn-system   engine-image-ei-b0369a5d-x2d4c                               1/1     Running   0               20d
longhorn-system   instance-manager-1d6bead33949064f7233434a3de5f523            1/1     Running   0               20d
longhorn-system   instance-manager-56db67d872d5bf6a86d3abc87cf5208b            1/1     Running   0               18d
longhorn-system   instance-manager-68c615a3a91cf9ebda953acf972752cf            1/1     Running   0               20d
longhorn-system   instance-manager-b15f49c4d8d12d04a7b42b556f0c07b4            1/1     Running   0               20d
longhorn-system   longhorn-csi-plugin-5cgc2                                    3/3     Running   0               20d
longhorn-system   longhorn-csi-plugin-nl9cf                                    3/3     Running   0               20d
longhorn-system   longhorn-csi-plugin-s6pgm                                    3/3     Running   0               20d
longhorn-system   longhorn-csi-plugin-sgpdt                                    3/3     Running   3 (18d ago)     20d
longhorn-system   longhorn-driver-deployer-784d685db-bpj7m                     1/1     Running   2 (20d ago)     20d
longhorn-system   longhorn-manager-c6cg2                                       1/1     Running   2 (18d ago)     20d
longhorn-system   longhorn-manager-wgrdr                                       1/1     Running   0               20d
longhorn-system   longhorn-manager-z28d9                                       1/1     Running   1 (20d ago)     20d
longhorn-system   longhorn-manager-zxfcn                                       1/1     Running   0               20d
longhorn-system   longhorn-ui-b6d4c957f-nm4hd                                  1/1     Running   0               20d
longhorn-system   longhorn-ui-b6d4c957f-qs49c                                  1/1     Running   0               20d
longhorn-system   share-manager-pvc-dee66439-33a0-45a4-9b2e-cd4d8c6f3e2a       1/1     Running   0               8d
longhorn-system   share-manager-pvc-e8d87a93-ef2d-44a0-9b79-28481853ceb2       1/1     Running   0               8d
prometheus        prometheus-for-amp-alertmanager-0                            1/1     Running   0               81m
prometheus        prometheus-for-amp-kube-state-metrics-54b456f7f6-27x7f       1/1     Running   0               81m
prometheus        prometheus-for-amp-prometheus-node-exporter-2r5xk            1/1     Running   0               81m
prometheus        prometheus-for-amp-prometheus-node-exporter-4fv5t            1/1     Running   0               81m
prometheus        prometheus-for-amp-prometheus-node-exporter-g2slq            1/1     Running   0               81m
prometheus        prometheus-for-amp-prometheus-node-exporter-wqzln            1/1     Running   0               81m
prometheus        prometheus-for-amp-prometheus-pushgateway-78d46bf9dd-8hdm2   1/1     Running   0               81m
prometheus        prometheus-for-amp-server-0                                  2/2     Running   0               81m
Admin:~/environment/amp $ 
```

## PromQL query to AMP
Define your AMP_QUERY_ENDPOINT that can be derived from AWS AMP Management Console or CLI.
https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-compatible-APIs.html
```
Admin:~/environment/amp $ awscurl -X POST --region us-east-1 --service aps "${AMP_QUERY_ENDPOINT}" -d 'query=up' --header 'Content-Type: application/x-www-form-urlencoded' | jq
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "up",
          "instance": "prometheus-for-amp-prometheus-pushgateway.prometheus.svc:9091",
          "job": "prometheus-pushgateway"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "eks_amazonaws_com_component": "kube-dns",
          "instance": "172.31.151.153:9153",
          "job": "kubernetes-service-endpoints",
          "k8s_app": "kube-dns",
          "kubernetes_io_cluster_service": "true",
          "kubernetes_io_name": "CoreDNS",
          "namespace": "kube-system",
          "node": "ip-172-31-148-193.ec2.internal",
          "service": "kube-dns"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-152-24.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-152-24.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "app_kubernetes_io_component": "metrics",
          "app_kubernetes_io_instance": "prometheus-for-amp",
          "app_kubernetes_io_managed_by": "Helm",
          "app_kubernetes_io_name": "prometheus-node-exporter",
          "app_kubernetes_io_part_of": "prometheus-node-exporter",
          "app_kubernetes_io_version": "1.8.2",
          "helm_sh_chart": "prometheus-node-exporter-4.39.0",
          "instance": "172.31.152.24:9100",
          "job": "kubernetes-service-endpoints",
          "namespace": "prometheus",
          "node": "ip-172-31-152-24.ec2.internal",
          "service": "prometheus-for-amp-prometheus-node-exporter"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "app_kubernetes_io_component": "metrics",
          "app_kubernetes_io_instance": "prometheus-for-amp",
          "app_kubernetes_io_managed_by": "Helm",
          "app_kubernetes_io_name": "prometheus-node-exporter",
          "app_kubernetes_io_part_of": "prometheus-node-exporter",
          "app_kubernetes_io_version": "1.8.2",
          "helm_sh_chart": "prometheus-node-exporter-4.39.0",
          "instance": "172.31.151.219:9100",
          "job": "kubernetes-service-endpoints",
          "namespace": "prometheus",
          "node": "ip-172-31-151-219.ec2.internal",
          "service": "prometheus-for-amp-prometheus-node-exporter"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-156-11.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-156-11.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "instance": "localhost:9090",
          "job": "prometheus"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-156-11.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes-cadvisor",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-156-11.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "app_kubernetes_io_component": "metrics",
          "app_kubernetes_io_instance": "prometheus-for-amp",
          "app_kubernetes_io_managed_by": "Helm",
          "app_kubernetes_io_name": "prometheus-node-exporter",
          "app_kubernetes_io_part_of": "prometheus-node-exporter",
          "app_kubernetes_io_version": "1.8.2",
          "helm_sh_chart": "prometheus-node-exporter-4.39.0",
          "instance": "172.31.156.11:9100",
          "job": "kubernetes-service-endpoints",
          "namespace": "prometheus",
          "node": "ip-172-31-156-11.ec2.internal",
          "service": "prometheus-for-amp-prometheus-node-exporter"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-151-219.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes-cadvisor",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-151-219.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "app_kubernetes_io_component": "metrics",
          "app_kubernetes_io_instance": "prometheus-for-amp",
          "app_kubernetes_io_managed_by": "Helm",
          "app_kubernetes_io_name": "prometheus-node-exporter",
          "app_kubernetes_io_part_of": "prometheus-node-exporter",
          "app_kubernetes_io_version": "1.8.2",
          "helm_sh_chart": "prometheus-node-exporter-4.39.0",
          "instance": "172.31.148.193:9100",
          "job": "kubernetes-service-endpoints",
          "namespace": "prometheus",
          "node": "ip-172-31-148-193.ec2.internal",
          "service": "prometheus-for-amp-prometheus-node-exporter"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-151-219.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-151-219.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "app_kubernetes_io_component": "metrics",
          "app_kubernetes_io_instance": "prometheus-for-amp",
          "app_kubernetes_io_managed_by": "Helm",
          "app_kubernetes_io_name": "kube-state-metrics",
          "app_kubernetes_io_part_of": "kube-state-metrics",
          "app_kubernetes_io_version": "2.13.0",
          "helm_sh_chart": "kube-state-metrics-5.25.1",
          "instance": "172.31.144.32:8080",
          "job": "kubernetes-service-endpoints",
          "namespace": "prometheus",
          "node": "ip-172-31-151-219.ec2.internal",
          "service": "prometheus-for-amp-kube-state-metrics"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "instance": "172.31.11.166:443",
          "job": "kubernetes-apiservers"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "eks_amazonaws_com_component": "kube-dns",
          "instance": "172.31.148.21:9153",
          "job": "kubernetes-service-endpoints",
          "k8s_app": "kube-dns",
          "kubernetes_io_cluster_service": "true",
          "kubernetes_io_name": "CoreDNS",
          "namespace": "kube-system",
          "node": "ip-172-31-156-11.ec2.internal",
          "service": "kube-dns"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "instance": "172.31.87.21:443",
          "job": "kubernetes-apiservers"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-152-24.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes-cadvisor",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-152-24.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-148-193.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-148-193.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      },
      {
        "metric": {
          "__name__": "up",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "c6id.8xlarge",
          "beta_kubernetes_io_os": "linux",
          "failure_domain_beta_kubernetes_io_region": "us-east-1",
          "failure_domain_beta_kubernetes_io_zone": "us-east-1d",
          "instance": "ip-172-31-148-193.ec2.internal",
          "is_worker": "true",
          "job": "kubernetes-nodes-cadvisor",
          "k8s_io_cloud_provider_aws": "20a68d84e101a9eb9385d6b0b5d7367d",
          "kubernetes_io_arch": "amd64",
          "kubernetes_io_hostname": "ip-172-31-148-193.ec2.internal",
          "kubernetes_io_os": "linux",
          "node_kubernetes_io_instance_type": "c6id.8xlarge",
          "node_longhorn_io_create_default_disk": "true",
          "storage": "longhorn",
          "topology_kubernetes_io_region": "us-east-1",
          "topology_kubernetes_io_zone": "us-east-1d"
        },
        "value": [
          1724994780,
          "1"
        ]
      }
    ]
  }
}
```
SRIOV METRICS

Update the AMP ConfigMap to take advantage of SRIOV metrics exporter: https://github.com/k8snetworkplumbingwg/sriov-network-metrics-exporter/tree/master.
Then restart/kill the `prometheus-for-amp-server-0` pod after the ConfigMap updated.

The full ConfigMap after SRIOV metrics exporter enabled:

https://github.com/sigitp-git/amp-prometheus-with-longhorn/blob/main/cm-prometheus-for-amp-server-n-prometheus-with-sriov.yaml 

```
global:
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  evaluation_interval: 1m
runtime:
  gogc: 75
alerting:
  alertmanagers:
  - authorization:
      type: Bearer
      credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: false
    follow_redirects: true
    enable_http2: true
    scheme: http
    timeout: 10s
    api_version: v2
    relabel_configs:
    - source_labels: [__meta_kubernetes_namespace]
      separator: ;
      regex: prometheus
      replacement: $1
      action: keep
    - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_instance]
      separator: ;
      regex: prometheus-for-amp
      replacement: $1
      action: keep
    - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
      separator: ;
      regex: alertmanager
      replacement: $1
      action: keep
    - source_labels: [__meta_kubernetes_pod_container_port_number]
      separator: ;
      regex: "9093"
      replacement: $1
      action: keep
    kubernetes_sd_configs:
    - role: pod
      kubeconfig_file: ""
      follow_redirects: true
      enable_http2: true
rule_files:
- /etc/config/recording_rules.yml
- /etc/config/alerting_rules.yml
- /etc/config/rules
- /etc/config/alerts
scrape_configs:
- job_name: prometheus
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - localhost:9090
- job_name: sriov-metrics
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_endpoint_node_name]
    separator: ;
    target_label: instance
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_target]
    separator: ;
    regex: "true"
    replacement: $1
    action: keep
  kubernetes_sd_configs:
  - role: endpoints
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
  static_configs:
  - targets:
    - sriov-metrics-exporter.monitoring.svc.cluster.local
- job_name: sriov-metrics-standalone
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__address__]
    separator: ;
    regex: ^(.*):\d+$
    target_label: __address__
    replacement: $1:9808
    action: replace
  - separator: ;
    target_label: __scheme__
    replacement: http
    action: replace
  kubernetes_sd_configs:
  - role: node
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-apiservers
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: https
  enable_compression: true
  authorization:
    type: Bearer
    credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    separator: ;
    regex: default;kubernetes;https
    replacement: $1
    action: keep
  kubernetes_sd_configs:
  - role: endpoints
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-nodes
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: https
  enable_compression: true
  authorization:
    type: Bearer
    credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - separator: ;
    regex: __meta_kubernetes_node_label_(.+)
    replacement: $1
    action: labelmap
  - separator: ;
    target_label: __address__
    replacement: kubernetes.default.svc:443
    action: replace
  - source_labels: [__meta_kubernetes_node_name]
    separator: ;
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/$1/proxy/metrics
    action: replace
  kubernetes_sd_configs:
  - role: node
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-nodes-cadvisor
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: https
  enable_compression: true
  authorization:
    type: Bearer
    credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - separator: ;
    regex: __meta_kubernetes_node_label_(.+)
    replacement: $1
    action: labelmap
  - separator: ;
    target_label: __address__
    replacement: kubernetes.default.svc:443
    action: replace
  - source_labels: [__meta_kubernetes_node_name]
    separator: ;
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
    action: replace
  kubernetes_sd_configs:
  - role: node
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-service-endpoints
  honor_labels: true
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
    separator: ;
    regex: "true"
    replacement: $1
    action: keep
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape_slow]
    separator: ;
    regex: "true"
    replacement: $1
    action: drop
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
    separator: ;
    regex: (https?)
    target_label: __scheme__
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
    separator: ;
    regex: (.+)
    target_label: __metrics_path__
    replacement: $1
    action: replace
  - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
    separator: ;
    regex: (.+?)(?::\d+)?;(\d+)
    target_label: __address__
    replacement: $1:$2
    action: replace
  - separator: ;
    regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
    action: labelmap
  - separator: ;
    regex: __meta_kubernetes_service_label_(.+)
    replacement: $1
    action: labelmap
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    target_label: namespace
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_service_name]
    separator: ;
    target_label: service
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_node_name]
    separator: ;
    target_label: node
    replacement: $1
    action: replace
  kubernetes_sd_configs:
  - role: endpoints
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-service-endpoints-slow
  honor_labels: true
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 5m
  scrape_timeout: 30s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape_slow]
    separator: ;
    regex: "true"
    replacement: $1
    action: keep
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
    separator: ;
    regex: (https?)
    target_label: __scheme__
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
    separator: ;
    regex: (.+)
    target_label: __metrics_path__
    replacement: $1
    action: replace
  - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
    separator: ;
    regex: (.+?)(?::\d+)?;(\d+)
    target_label: __address__
    replacement: $1:$2
    action: replace
  - separator: ;
    regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
    action: labelmap
  - separator: ;
    regex: __meta_kubernetes_service_label_(.+)
    replacement: $1
    action: labelmap
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    target_label: namespace
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_service_name]
    separator: ;
    target_label: service
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_node_name]
    separator: ;
    target_label: node
    replacement: $1
    action: replace
  kubernetes_sd_configs:
  - role: endpoints
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: prometheus-pushgateway
  honor_labels: true
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_probe]
    separator: ;
    regex: pushgateway
    replacement: $1
    action: keep
  kubernetes_sd_configs:
  - role: service
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-services
  honor_labels: true
  honor_timestamps: true
  track_timestamps_staleness: false
  params:
    module:
    - http_2xx
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /probe
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_probe]
    separator: ;
    regex: "true"
    replacement: $1
    action: keep
  - source_labels: [__address__]
    separator: ;
    target_label: __param_target
    replacement: $1
    action: replace
  - separator: ;
    target_label: __address__
    replacement: blackbox
    action: replace
  - source_labels: [__param_target]
    separator: ;
    target_label: instance
    replacement: $1
    action: replace
  - separator: ;
    regex: __meta_kubernetes_service_label_(.+)
    replacement: $1
    action: labelmap
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    target_label: namespace
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_service_name]
    separator: ;
    target_label: service
    replacement: $1
    action: replace
  kubernetes_sd_configs:
  - role: service
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-pods
  honor_labels: true
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 1m
  scrape_timeout: 10s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
    separator: ;
    regex: "true"
    replacement: $1
    action: keep
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape_slow]
    separator: ;
    regex: "true"
    replacement: $1
    action: drop
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scheme]
    separator: ;
    regex: (https?)
    target_label: __scheme__
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
    separator: ;
    regex: (.+)
    target_label: __metrics_path__
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    separator: ;
    regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
    target_label: __address__
    replacement: '[$2]:$1'
    action: replace
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    separator: ;
    regex: (\d+);((([0-9]+?)(\.|$)){4})
    target_label: __address__
    replacement: $2:$1
    action: replace
  - separator: ;
    regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
    action: labelmap
  - separator: ;
    regex: __meta_kubernetes_pod_label_(.+)
    replacement: $1
    action: labelmap
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    target_label: namespace
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_name]
    separator: ;
    target_label: pod
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_phase]
    separator: ;
    regex: Pending|Succeeded|Failed|Completed
    replacement: $1
    action: drop
  - source_labels: [__meta_kubernetes_pod_node_name]
    separator: ;
    target_label: node
    replacement: $1
    action: replace
  kubernetes_sd_configs:
  - role: pod
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
- job_name: kubernetes-pods-slow
  honor_labels: true
  honor_timestamps: true
  track_timestamps_staleness: false
  scrape_interval: 5m
  scrape_timeout: 30s
  scrape_protocols:
  - OpenMetricsText1.0.0
  - OpenMetricsText0.0.1
  - PrometheusText0.0.4
  metrics_path: /metrics
  scheme: http
  enable_compression: true
  follow_redirects: true
  enable_http2: true
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape_slow]
    separator: ;
    regex: "true"
    replacement: $1
    action: keep
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scheme]
    separator: ;
    regex: (https?)
    target_label: __scheme__
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
    separator: ;
    regex: (.+)
    target_label: __metrics_path__
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    separator: ;
    regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
    target_label: __address__
    replacement: '[$2]:$1'
    action: replace
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    separator: ;
    regex: (\d+);((([0-9]+?)(\.|$)){4})
    target_label: __address__
    replacement: $2:$1
    action: replace
  - separator: ;
    regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
    action: labelmap
  - separator: ;
    regex: __meta_kubernetes_pod_label_(.+)
    replacement: $1
    action: labelmap
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    target_label: namespace
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_name]
    separator: ;
    target_label: pod
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_phase]
    separator: ;
    regex: Pending|Succeeded|Failed|Completed
    replacement: $1
    action: drop
  - source_labels: [__meta_kubernetes_pod_node_name]
    separator: ;
    target_label: node
    replacement: $1
    action: replace
  kubernetes_sd_configs:
  - role: pod
    kubeconfig_file: ""
    follow_redirects: true
    enable_http2: true
remote_write:
- url: https://aps-workspaces.us-east-1.amazonaws.com/workspaces/ws-7c0e42fa-672e-408e-9970-f4343ff6233f/api/v1/remote_write
  remote_timeout: 30s
  protobuf_message: prometheus.WriteRequest
  follow_redirects: true
  enable_http2: true
  queue_config:
    capacity: 2500
    max_shards: 200
    min_shards: 1
    max_samples_per_send: 1000
    batch_send_deadline: 5s
    min_backoff: 30ms
    max_backoff: 5s
  metadata_config:
    send: true
    send_interval: 1m
    max_samples_per_send: 2000
  sigv4:
    region: us-east-1
```
