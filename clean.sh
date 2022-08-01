CLUSTER=web-test2
ZONE=asia-east1-a

# delete the forwarding-rule aka frontend
gcloud -q compute forwarding-rules delete $CLUSTER-forwarding-rule --global
# delete the http proxy
gcloud -q compute target-http-proxies delete $CLUSTER-target-proxy
# delete the url map
gcloud -q compute url-maps delete $CLUSTER-url-map
# delete the backend
gcloud -q compute backend-services delete $CLUSTER-lb-backend --global
# delete the health check
gcloud -q compute health-checks delete $CLUSTER-health-check
# delete the firewall rule
gcloud -q compute firewall-rules delete $CLUSTERE-lb-fw
# delete the cluster
gcloud -q container clusters delete $CLUSTER --zone=$ZONE
# delete the NEG  
gcloud compute network-endpoint-groups delete $CLUSTER-neg --zone=$ZONE