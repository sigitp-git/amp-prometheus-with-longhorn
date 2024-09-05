Admin:~/environment $ kubectl get svc -A
NAMESPACE         NAME                                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default           kubernetes                                    ClusterIP   172.20.0.1       <none>        443/TCP                  14d
kube-system       kube-dns                                      ClusterIP   172.20.0.10      <none>        53/UDP,53/TCP,9153/TCP   14d
longhorn-system   longhorn-admission-webhook                    ClusterIP   172.20.22.147    <none>        9502/TCP                 6d6h
longhorn-system   longhorn-backend                              ClusterIP   172.20.146.121   <none>        9500/TCP                 6d6h
longhorn-system   longhorn-conversion-webhook                   ClusterIP   172.20.226.177   <none>        9501/TCP                 6d6h
longhorn-system   longhorn-engine-manager                       ClusterIP   None             <none>        <none>                   6d6h
longhorn-system   longhorn-frontend                             ClusterIP   172.20.185.225   <none>        80/TCP                   6d6h
longhorn-system   longhorn-recovery-backend                     ClusterIP   172.20.179.121   <none>        9503/TCP                 6d6h
longhorn-system   longhorn-replica-manager                      ClusterIP   None             <none>        <none>                   6d6h
monitoring        sriov-metrics-exporter                        ClusterIP   172.20.216.52    <none>        9808/TCP                 5h9m
prometheus        prometheus-for-amp-alertmanager               ClusterIP   172.20.29.204    <none>        9093/TCP                 6d5h
prometheus        prometheus-for-amp-alertmanager-headless      ClusterIP   None             <none>        9093/TCP                 6d5h
prometheus        prometheus-for-amp-kube-state-metrics         ClusterIP   172.20.21.134    <none>        8080/TCP                 6d5h
prometheus        prometheus-for-amp-prometheus-node-exporter   ClusterIP   172.20.253.113   <none>        9100/TCP                 6d5h
prometheus        prometheus-for-amp-prometheus-pushgateway     ClusterIP   172.20.239.61    <none>        9091/TCP                 6d5h
prometheus        prometheus-for-amp-server                     ClusterIP   172.20.246.95    <none>        80/TCP                   6d5h
prometheus        prometheus-for-amp-server-headless            ClusterIP   None             <none>        80/TCP                   6d5h

Admin:~/environment $ kubectl describe svc  prometheus-for-amp-server -n prometheus
Name:              prometheus-for-amp-server
Namespace:         prometheus
Labels:            app.kubernetes.io/component=server
                   app.kubernetes.io/instance=prometheus-for-amp
                   app.kubernetes.io/managed-by=Helm
                   app.kubernetes.io/name=prometheus
                   app.kubernetes.io/part-of=prometheus
                   app.kubernetes.io/version=v2.54.1
                   helm.sh/chart=prometheus-25.27.0
Annotations:       meta.helm.sh/release-name: prometheus-for-amp
                   meta.helm.sh/release-namespace: prometheus
Selector:          app.kubernetes.io/component=server,app.kubernetes.io/instance=prometheus-for-amp,app.kubernetes.io/name=prometheus
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                172.20.246.95
IPs:               172.20.246.95
Port:              http  80/TCP
TargetPort:        9090/TCP
Endpoints:         10.0.62.85:9090
Session Affinity:  None
Events:            <none>
Admin:~/environment $ 

# port forward the endpoint IP and port via SSH to worker node
ssh -i file.pem -L 8000:172.31.149.220:9090 ec2-user@ec2-184-72-87-109.compute-1.amazonaws.com
ssh -i file.pem -L 8000:172.31.151.158:9090 ec2-user@ec2-34-229-218-164.compute-1.amazonaws.com
