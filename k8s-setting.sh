# Upon creating the Ingress, an HTTP(S) load balancer is created in the project, and NEGs are created in each zone in which the cluster runs.
# The endpoints in the NEG and the endpoints of the Service are kept in sync.
# zonal GCE_VM_IP_PORT network endpoint group (NEG) in a Google Kubernetes Engine (GKE) VPC-native cluster.


PROJECT=skye-personal
REGION=asia-east1
ZONE=asia-east1-a

LB=web-test-lb
NETWORK="${LB}-network"

CLUSTER=web-test
ZONE=asia-east1-a



#vpc
#custom - create the subnets that you want within a region 
#You do not have to specify subnets for all regions right away,
# gcloud compute networks create $NETWORK \
# --subnet-mode=custom \
# --mtu=1460 \
# --bgp-routing-mode=global 
#

# use default network
#--cluster-ipv4-cidr , The IP address range for the pods in this cluster 
#--services-ipv4-cidr , Set the IP range for the services IPs.
gcloud container clusters create $CLUSTER \
    --num-nodes 1 \
    --machine-type e2-medium \
    --enable-ip-alias \
    --create-subnetwork name=k8s-backend-subnet\
    --network=default \
    --zone=$ZONE \
    --cluster-ipv4-cidr=10.0.0.0/14 \
    --services-ipv4-cidr=10.4.0.0/19


gcloud container clusters resize $CLUSTER --node-pool default-pool \
    --num-nodes 3


# static ip
gcloud compute addresses create --global

# SSL certificate
kubectl create secret tls web-test.cert \
    --cert ssl/web-test.crt --key ssl/web-test.key

kubectl get secrets

# manage node pool
# https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools#deploy

# check node pool
gcloud container node-pools list --cluster $CLUSTER
gcloud container node-pools describe default-pool 

# gcloud container node-pools create custom-pool \
#   --cluster=$CLUSTER \
#   --machine-type=e2-medium\
#   --num-nodes=1 \
#   --disk-type pd-ssd \
#   --disk-size 20 

# delete node pool
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-emptydir-data --grace-period=10 "$node";
done

gcloud container node-pools delete default-pool --cluster $CLUSTER


# health check 
 - 需要設定

#https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing