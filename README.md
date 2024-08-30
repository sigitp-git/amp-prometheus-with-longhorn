# prometheus-with-longhorn
Enabling prometheus on EC2 instances without EBS CSI, but using Longhorn instead. Useful for Outposts servers or other instance store EC2 instances type.
Ingestion towards Amazon Managed Service for Prometheus (AMP) workspaces as described here: https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/

## usage
```
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

## longhorn pv and pvc
```
Admin:~/environment/amp $ kubectl get pvc -A
NAMESPACE    NAME                                         STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
default      longhorn-pvc                                 Bound         pvc-e8d87a93-ef2d-44a0-9b79-28481853ceb2   10Gi       RWX            longhorn-sc    <unset>                 20d
default      longhorn-pvc2                                Terminating   pvc-dee66439-33a0-45a4-9b2e-cd4d8c6f3e2a   10Gi       RWX            longhorn-sc2   <unset>                 15d
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
