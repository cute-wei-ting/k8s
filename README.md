# k8s

架構
--
- External HTTP(S) Load Balancing(classic)
- Container-native load balancing

  > `kube-proxy configures nodes' iptables rules to distribute traffic to Pods.` Without container-native load balancing, load balancer traffic travels to the node instance groups and gets routed via iptables rules to Pods which might or might not be in the same node. `With container-native load balancing, load balancer traffic is distributed directly to the Pods which should receive the traffic, eliminating the extra network hop`. Container-native load balancing also helps with improved health checking since it targets Pods directly.

- Comparison of default load balancer with container-native load balancer

  ![neg image](https://cloud.google.com/static/kubernetes-engine/images/neg.svg)

- [k8s-setting](k8s-setting.sh)
  - dns
  - backend
  
  依其設定及後端建置
  - vpc,backend-subnet
  - firewall
  - lb ip address,forwarding-rules
  - target-proxy,SSL certificate
  - url-map
  - backend-service(Network Endpoint Group)


backend
--
- ingress
- service
- development 


domain and SSL
--
`skisle-region.tk,www.skisle-region.tk`
- domain
 freenom(free,1year)
- SSL
 ZeroSSL(free,90day)

Question
--
- cloudflare ssl not offiial

  https://developers.cloudflare.com/ssl/origin-configuration/origin-ca
  ```
  Origin CA certificates only encrypt traffic between Cloudflare and your origin web server and are not trusted by client browsers when directly accessing your origin website outside of Cloudflare. For subdomains that utilize Origin CA certificates, pausing or disabling Cloudflare causes untrusted certificate errors for site visitors.

  ```
- region lb drawbacks
  - Google-managed SSL certificates aren't supported for regional external HTTP(S) load balancers and internal HTTP(S) load balancers
  - google storage bucket backend only support global lb

採坑
--
- cluster default pool 的 machine 配置要夠,cpu and meomory 不能自己配得太小
- service spec.selector 要對到 pod label 
- The Service's annotation, `cloud.google.com/neg: '{"ingress": true}'`, enables container-native load balancing.
- neg healthCheck 會吃不到需要自行設定

Reference
--

- [Container-native load balancing through Ingress ](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing)


 - [Container-native load balancing through standalone zonal NEGs ](https://cloud.google.com/kubernetes-engine/docs/how-to/standalone-neg)

    - [custom](custom.sh)
      - vpc,backend-subnet,proxy-only-subnet
      - firewall
      - lb ip address,forwarding-rules
      - target-proxy,SSL certificate
      - url-map
      - backend-service(instance-groups)
      - cluster

    - image
      ![standalone negs image](https://cloud.google.com/static/kubernetes-engine/images/sneg2.svg)
   


