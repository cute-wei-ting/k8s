# k8s

架構
--
- regional external HTTP(S) load balancer 
![lb structure image](https://cloud.google.com/static/load-balancing/images/regional-l7xlb-numbered-components.svg)
- [infrastructure](infrastructure.sh)
  - vpc,backend-subnet,proxy-only-subnet
  - firewall
  - lb ip address,forwarding-rules
  - target-proxy,SSL certificate
  - url-map
  - backend-service(instance-groups)
  - cluster

domain and SSL
--
`skisle.tk,www.skisle.tk`
- domain
 freenom(free,1year)
- SSL
 cloudflare(free,15year)


backend
--
- ingress
- service
- development 