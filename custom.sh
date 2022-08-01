
PROJECT=skye-personal
REGION=asia-east1
ZONE=asia-east1-a

LB=web-test-lb
NETWORK="${LB}-network"

CLUSTER=web-test

#vpc
gcloud compute networks create $NETWORK \
--project=$PROJECT \
--subnet-mode=custom \
--mtu=1460 \
--bgp-routing-mode=regional

#subnets
gcloud compute networks subnets create backend-subnet \
--project=$PROJECT \
--description=\後\端\服\務\子\網\路 \
--range=10.1.2.0/24 \
--stack-type=IPV4_ONLY \
--network=$NETWORK \
--region=$REGION \
--enable-private-ip-google-access 

#proxy
gcloud compute networks subnets create proxy-only-subnet \
  --purpose=REGIONAL_MANAGED_PROXY \
  --role=ACTIVE \
  --region=$REGION \
  --network=$NETWORK \
  --range=10.129.0.0/23

#firewall
gcloud compute firewall-rules create fw-allow-health-check \
    --network=$NETWORK \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=load-balanced-backend \
    --rules=tcp

gcloud compute firewall-rules create fw-allow-proxies \
  --network=$NETWORK \
  --action=allow \
  --direction=ingress \
  --source-ranges=10.129.0.0/23 \
  --target-tags=load-balanced-backend \
  --rules=tcp:80,tcp:443,tcp:8080

#lb ip
gcloud compute addresses create "${LB}-ip"  \
   --region=$REGION \
   --network-tier=STANDARD

# backend-services
gcloud compute health-checks create http "${LB}-basic-check" \
   --region=$REGION \
   --request-path='/' \
   --port 80

gcloud compute backend-services create "${LB}-backend-service" \
  --load-balancing-scheme=EXTERNAL_MANAGED \
  --protocol=HTTP \
  --port-name=http \
  --health-checks="${LB}-basic-check"  \
  --health-checks-region=$REGION\
  --region=$REGION

igawk="match(\$2, /gke\-${CLUSTER}\-default\-pool/){print \$2}"
INSTANCE_GROUP=`gcloud compute instance-groups list | awk "$igawk"`

gcloud compute backend-services add-backend "${LB}-backend-service" \
  --balancing-mode=UTILIZATION \
  --max-utilization 0.8 \
  --instance-group=$INSTANCE_GROUP \
  --instance-group-zone=$ZONE \
  --region=$REGION

# lb setting
gcloud compute url-maps create "${LB}-map" \
  --default-service="${LB}-backend-service" \
  --region=$REGION

gcloud compute ssl-certificates create "${LB}-ssl-cert" \
 --certificate=ssl/web-test.crt \
 --private-key=ssl/web-test.key \
 --region=$REGION

gcloud compute target-https-proxies create "${LB}-proxy" \
 --url-map="${LB}-map" \
 --region=$REGION \
 --ssl-certificates="${LB}-ssl-cert"

gcloud compute forwarding-rules create "${LB}-forwarding-rule" \
  --load-balancing-scheme=EXTERNAL_MANAGED \
  --network-tier=STANDARD \
  --network=$NETWORK \
  --address="${LB}-ip" \
  --ports=443 \
  --region=$REGION \
  --target-https-proxy="${LB}-proxy" \
  --target-https-proxy-region=$REGION

#k8s cluster web-test 
gcloud beta container --project $PROJECT clusters create $CLUSTER --zone $ZONE --no-enable-basic-auth --cluster-version "1.22.8-gke.202" --release-channel "regular" --machine-type "e2-small" --image-type "COS_CONTAINERD" --disk-type "pd-ssd" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "1" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/skye-personal/global/networks/web-test-lb-network" --subnetwork "projects/skye-personal/regions/asia-east1/subnetworks/backend-subnet" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations $ZONE


gcloud dns --project=skye-personal managed-zones create asia-east1-a --description="" --dns-name="skisle.tk." --visibility="public" --dnssec-state="off"