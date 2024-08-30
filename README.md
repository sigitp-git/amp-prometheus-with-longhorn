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
