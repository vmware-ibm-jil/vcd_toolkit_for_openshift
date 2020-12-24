### Overview
[VCD Toolkit for OpenShift Overview here](https://github.com/vmware-ibm-jil/vcd_toolkit_for_openshift)

The VCD Toolkit will deploy OpenShift(OCP) into an environment based on IBM Cloud VMware Solutions Shared, which is based on VMWare Cloud Director (VCD).
This is a shared VMWare based environment where we can provision our own VMs and networks.  It comes with an Edge Gateway which will isolate our virtual datacenter from the Internet as needed. 
We can create as many networks/subnets, routes, firewalls, and VMs as we need.

#### About IBM Cloud VMWare Solution Shared and VMWare Cloud Director
For those who are familiar with VMWare, think of Cloud Director as a big PostgreSQL database and a streamlined modern web UI on top of a vCenter and  NSX APIs, and ESXi infrastructure.  All actions taken in the VCD console are pushed to vCenter and govc API's.  The beauty is that only the essentials of VCenter/NSX are surfaced and modernized for true cloud based virtual datacenter operations.  All vCenter, NSX, and ESXi maintenance and upgrades are handled by the IBM Solution Shared team for you.  You have no direct access to vCenter, NSX, or ESXi.

The **IBMCloud VMWare Solution Shared** is a payGo environment. You pay a low monthly fee, and after that you pay for VM vCPU and Memory based on usage.  Each instance comes with 5 public IP addresses, and a RedHat subscription.

#### Install approach
The overall approach is a **Bare Metal Install**, also known as UPI - User provisioned Infrastructure.  The  [OpenShift 4.1 Bare Metal Install Quickstart](https://www.openshift.com/blog/openshift-4-bare-metal-install-quickstart) and [Install with Static IPs](https://www.openshift.com/blog/openshift-4-2-vsphere-install-with-static-ips) and [OpenShift 4.2 VSphere Quickstart](https://www.openshift.com/blog/openshift-4-2-vsphere-install-quickstart) describe the approach that is followed by the vcd_toolkit_for_openshift.

## Ordering
You order **VMware Solutions Shared** in IBM Cloud.  When you order a new instance, a **DataCenter** is created in vCloud Director.  It takes about an hour.

#### Procedure:
* in IBM Cloud > VMWare > Overview,  select **VMWare Solutions Shared**
* name your virtual data center
* pick the resource group.  
* agree to the terms and click `Create`
* then in VMware Solutions > Resources you should see your VMWare Solutions Shared being created.  After an hour or less it will be **ready to use**

### First time setup
* click on the VMWare Shared Solution instance named from the Resources list
* set your admin password, and save it
* click the button to launch your  **vCloud Director console**
* we recommend that you create individual Users/passwords for each person accessing the environment
* Note: You don't need any Private network Endpoints unless you want to access the VDC from other IBM Cloud accounts over Private network

## Choose an Image Catalog

We need a catalog of VM images to use for our OpenShift VMs.
Fortunately IBM provides a set of images that are tailored to work for OpenShift deployments.
To browse the available images:
* From your vCloud Director console, click on **Libraries** in the header menu.
* select *vApp Templates*
* There are 3 images in the list that we will be using:
  * rhcos OpenShift 4.5.6 - OpenShift CoreOS template
  * rhcos OpenShift 4.4.17 - OpenShift CoreOS template
  * lbopenshiftv2 - Load balancer template
* If you want to add your own Catalogs and more, see the [documentation about catalogs](#about-catalogs)

## Networking
Much of the following is covered in general in the [Operator Guide/Networking](https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide#shared_vcd-ops-guide-networking). Below is the specific network configuration required.

### Create private networks

Create a network where we will install VMs and OCP.
* Go to main menu > Networking > Networks and select **NEW** or **ADD**
  - Select Network Type: `Routed`
  - General:
    - Name:  **ocpnet**
    - Gateway/CIDR: **172.16.0.1/24**
    - Shared - leave it toggled off
  - Edge:  
    - connect to your ESG
    - Interface Type:  **Internal**  (changed from **Distributed** temporarily due to a bug in VMWare. Not sure if its really necessary to change back? )
    - Guest Vlan Allowed: **no**
  - Static IP Pools:
     - convenient for establishing a range that you manually assign from.   **172.16.0.10 - 172.16.0.18**
  - DNS: Use Edge DNS -  toggled off.  Set primary DNS to 172.16.0.10 which is where we will put the Bastion VM.  This is the DNS that will be used by default for VMs created with static or pool based IP addresses.


### Configure edge networking
We need to configure the Edge Service Gateway (ESG) to provide inbound and outbound connectivity.  For a network overview diagram, followed by general Edge setup instruction, see: https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide#shared_vcd-ops-guide-create-network

Each vCloud Datacenter comes with 5 IBM Cloud public IP addresses which we can use for SNAT and DNAT translations in and out of the datacenter instance.  VMWare vCloud calls these `sub-allocated` addresses.

Gather the IPs and Sub-allocated IP Addresses for the ESG, for future reference:
* The sub-allocated address are available in IBM Cloud on the vCloud instance Resources page.    
* Go to main menu > Networking > Edges,  and Select your ESG
  - Go to `Networks and subnets` and copy down the `Participating Subnets` of the `tenant-external` and `servicexx` external networks. (we will need this info later)
    - the tenant-external network allows external internet routing
    - the service network allows routing to IBM Cloud private network /services

For the following steps go to main menu > Networks > Edges > Select your ESG and select **SERVICES** 

See also https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide#shared_vcd-ops-guide-enable-traffic

**Note:** make modifications by editing the various columns on the screen as instructed below.

#### Outbound from the OCP private network to public Internet
1. Firewall Rule
    - Firewall tab and select '+' to add
      - Name: **ocpnet**
      - Source: Select the '+'
        - select 'Org Vdc Networks' from the objects type list
        - select 'ocpnet' from list and then click '->' and 'Keep'
      - Destination: skip. (this will become "any" in the Firewall Rules screen)
     - Select: 'Save changes'

2. NAT
    - NAT tab and select '+SNAT RULE' in the NAT44 Rules
      - Applied On: **<your>-tenant-external**
      - Original Source IP/Range: **172.16.0.1/24**
      - Translated Source IP/Range: pick an address not already used address from the sub-allocated network IPs
      - Description: **ocpnet outbound**

#### Outbound from OCP private network to IBM Cloud private network
[Official instruction to connect to the IBM Cloud Services Private Network](https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide#shared_vcd-ops-guide-enable-access).  Our shorthand setup steps:
1. Firewall Rule
    - Firewall tab and select '+' to add
      - Name: **ocpnet cloud-private**
      - Source: Select the '+'
        - select 'Org Vdc Networks' from the objects type list
        - select 'ocpnet' from list and then click '->' and 'Keep'
      - Destination: Select the '+'
        - select 'Gateway Interfaces' from the objects type list
        - select **<your>-service-nn** network from list and then click '->' and 'Keep'. (this will become "vnic-1" in the Firewall Rules screen)
     - Select: 'Save changes'

2. NAT
    - NAT tab and select '+SNAT RULE' in the NAT44 Rules
      - Applied On: **<your>-service-nn**
      - Original Source IP/Range: **172.16.0.1/24**
      - Translated Source IP/Range: enter the `Primary IP` for the service network interface copied from the ESG settings (Or select it from the dropdown list)
      - Description: **access to the IBM Cloud private**

#### Inbound config to the bastion on OCP private network
We need to configure DNAT so that we have ssh access the bastion VM from public internet.
  - Choose an available IP Address from the set of `public/sub-allocated` IPs for the VCD datacenter instance.
  - We will use  172.16.0.10 address for bastion VM
1. Firewall Rule
    - Firewall tab and select '+' to add
      - Name: **bastion**
      - Destination: tap the 'IP' button
        - choose an available IP from your list of  `public/sub-allocated IPs` and enter it 
      - Service: Protocol: `TCP` Source port: `any` Destination port: `22`
     - Select: 'Save changes'

2. NAT
    - NAT tab and select '+DNAT RULE' in the NAT44 Rules
      - Applied On: **your-tenant-external**
      - Original Source IP/Range: enter the same public IP that you used in the firewall rule
      - Translated Source IP/Range: **172.16.0.10**
      - Description: **access to bastion host**

#### Inbound config to OCP Console
We need to configure DNAT so that we have https access the console from public internet.
  - Choose an available IP Address from the set of `public/sub-allocated` IPs for the VCD datacenter instance.
1. Firewall Rule
    - Firewall tab and select '+' to add
      - Name: **ocpconsole**
      - Destination: Select the 'IP'
        - enter the `chosen public/sub-allocated IP`
      - Service: Protocol: `any`
     - Select: 'Save changes'

2. NAT
    - NAT tab and select '+DNAT RULE' in the NAT44 Rules
      - Applied On: **your-tenant-external**
      - Original Source IP/Range: enter the `chosen public/sub-allocated IP`
      - Translated Source IP/Range: **IP of Load Balancer**
      - Description: **access to ocp console**


#### Setup DHCP
* We will use our Edge gateway to provide DHCP services.  On the Edge > DHCP, click + and configure DHCP with the following settings:
    ```
    IPRange: 172.16.0.150-172.16.0.245
    Primary Nameserver: 172.16.0.10 (bastion)
    AutoConfig DNS: no
    Gateway: 172.16.0.1
    Netmask: 255.255.255.0
    Lease: 86400
    ```
* Toggle DHCP Service on

* TODO - should document creating a simple VM or 2 for testing.
* check if DHCP is up:  From a VM `sudo nmap --script broadcast-dhcp-discover`
    This should return you a DHCPOFFER.  If not, DHCP is not configured and enabled on the edge.  Confirm the ip offered, netmask, router/gateway, and DNS server.  For example:

```
Starting Nmap 6.40 ( http://nmap.org ) at 2020-08-25 15:38 EDT
Pre-scan script results:
| broadcast-dhcp-discover:
|   IP Offered: 172.16.0.151
|   DHCP Message Type: DHCPOFFER
|   Server Identifier: 169.254.1.73
|   IP Address Lease Time: 0 days, 0:05:00
|   Subnet Mask: 255.255.255.0
|   Router: 172.16.0.1
|_  Domain Name Server: 172.16.0.10
```


## Create and configure Bastion VM
The Bastion VM hosts the vcd_toolkit_for_openshift and  is the VM where we launch installations from.  The VM also hosts **DNS service**, and an **HTTP server** through which the Ignition configuration files are provided to Bootstrap during installation.

Go to Virtual Machines > **New VM**
Name: **bastion**
  - **From Template**
  - Select **vm-redhat7**

After the VM is created, connect it to your network:
 - from Virtual Machines, select bastion VM
  - Details > Hardware > **NICs**
    - select **Connected**
    - Network = **ocpnet**
    - IP Mode = **Static - Manual**
    - IP Address **172.16.0.10**
    - Click **Save**  

#### Enable Redhat entitlement
  * You need to enable RedHat entitlement so that you can use yum.
  * ssh to bastion and execute the [steps in bullet 3 here](https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide#shared_vcd-ops-guide-public-cat-rhel) to register the VM

#### Install DNS - based on dnsmasq
`yum install dnsmasq`

DHCP service must be turned off by adding the following entry in /etc/dnsmasq.conf for each interface and temporarily add internet access so you can clone repository, etc.:
  ```
  no-dhcp-interface=ens192
  server=9.9.9.9
  listen-address=127.0.0.1
  interface=ens192
  interface=lo

  ```
    * `systemctl enable dnsmasq.service` # so that dnsmasq will start after reboot
    * `systemctl start dnsmasq.service`
#### Install preReqs of the Terraform  and SimpleHTTP server:
  - `yum install uzip`
  - `yum install python3`
  - `yum install -y yum-utils`
  - `yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo`
  - `yum install terraform`


#### Update firewall
Allow HTTP(port 80) and DNS(port 53) traffic into bastion.  Issue the following commands.  You should get `success` message from each:
```
firewall-cmd --add-port=80/tcp --zone=public --permanent
firewall-cmd --add-port=53/tcp --zone=public --permanent
firewall-cmd --add-port=53/udp --zone=public --permanent
firewall-cmd --reload
```
[More about firewalld](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-using_firewalls#sec-Getting_started_with_firewalld)


`netstat -aunp`
```
 ...
udp        0      0 0.0.0.0:53              0.0.0.0:*                           1202/dnsmasq         
```

**Note: the following verifications need to be done after running the add_dns.sh script.( in the Update DNS step below)**

* Verify that DNS lookups are good, and going to the right SERVER:

`dig worker-00.myprefix.my.com`
```...
;; ANSWER SECTION:
worker-00.myprefix.my.com. 0	IN	A	172.16.0.24
...
SERVER: 127.0.0.1#53(127.0.0.1)
```

* Verify that your SRV records are in DNS:   

`dig _etcd-server-ssl._tcp.myprefix.my.com SRV`
```
;; ANSWER SECTION:
_etcd-server-ssl._tcp.myprefix.my.com. 0 IN SRV 10 0 2380 etcd-1.myprefix.my.com.
_etcd-server-ssl._tcp.myprefix.my.com. 0 IN SRV 10 0 2380 etcd-0.myprefix.my.com.
_etcd-server-ssl._tcp.myprefix.my.com. 0 IN SRV 10 0 2380 etcd-2.myprefix.my.com.

;; ADDITIONAL SECTION:
etcd-0.myprefix.my.com. 0	IN	A	172.16.0.21
etcd-2.myprefix.my.com. 0	IN	A	172.16.0.23
etcd-1.myprefix.my.com. 0	IN	A	172.16.0.22

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
```
To check what lines are active in dnsmasq.conf:


`grep -v -e '^#' -e '^$'  /etc/dnsmasq.conf`
```    
    server=8.8.8.8
    listen-address=::1,127.0.0.1,172.16.0.10
    no-dhcp-interface=ens192
    expand-hosts
    domain=myprefix.my.com
    conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
    address=/.apps.myprefix.my.com/172.16.0.19
    srv-host="_etcd-server-ssl._tcp.myprefix.my.com",etcd-0.myprefix.my.com,2380,10,0
    srv-host="_etcd-server-ssl._tcp.myprefix.my.com",etcd-1.myprefix.my.com,2380,10,0
    srv-host="_etcd-server-ssl._tcp.myprefix.my.com",etcd-2.myprefix.my.com,2380,10,0

```

#### Start HTTP Server
The HTTP Server is used by the bootstrap and other coreOS nodes to retrieve their ignition files.
* Important: start the server from / directory so that path to ignition files is correct!
* `cd /; nohup python -m SimpleHTTPServer 80 &`
* Note: to see requests to the server `tail -f /nohup.out`

#### Install VCD Toolkit
* clone this repo
* `cp -r <this repo>/src/* /usr/local/openshift/`

Now the toolkit is installed in `/usr/local/openshift`

* The toolkit supports the deployment of OCP 4.4 or 4.5 with 3 master and 3 worker nodes without any storage provisioners.
    - TODO: allow for flexible number of worker nodes. Changes would have to occur in env.sh.template, create_ignition.sh, deploy.sh, LBDNS.xml, main.tf.withProperties and vcd.sh
    - TODO: make scripts generic to OCP versions allowing user to specify version and change create_ignition.sh to use appropriate installer version binary

#### Install OpenShift

#### Update env.sh:
`env.sh` will contain all the configuration for your cluster.
See `this repo`/config/env.sh which is self documenting.
At this point you need to choose a BASEDOMAIN, and PREFIXTODOMAIN which will become your FQDN.
The default $PREFIXTODOMAIN.$BASEDOMAIN in env.sh is `myprefix.my.com`.
* `mkdir /home/yourhome/$PREFIXTODOMAIN`
* `cd /home/yourHome/$PREFIXTODOMAIN`  
* `cp this-repo/config/env.sh /home/yourHome/$PREFIXTODOMAIN`   
* Fill in the variables in env.sh as documented in env.sh itself.

#### Create Ignition files, install-config.yaml, and ssh keys:
* Execute `PATH=$PATH:/usr/local/openshift;export PATH`
* Retrieve a pull secret from [Red Hat OCP on vSphere Installation Instructions](https://cloud.redhat.com/openshift/install/vsphere/user-provisioned) and place in `/tmp/pull-secret.txt`

  **Note:** Don't download the installation and client code from this page unless you are installing the current version of OpenShift (currently 4.6.x which is not yet supported by the vcd_toolkit_for_openshift)
* _Step not necessary as this was removed by sdl. create_ignition.sh and  change line 10 to point to the correct openshift-install binary_
* Download the appropriate OpenShift Install and client code from here:
[Red Hat Download Site (choose appropriate version)](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/) Additional OCP install details can be found here: [OCP 4.5 Install instructions but choose proper version.](https://docs.openshift.com/container-platform/4.5/installing/installing_vsphere/installing-vsphere-installer-provisioned.html). Untar the files and place `openshift-install` in /usr/local/openshift and the `oc` and `kubectl` command in /usr/local/bin

    Example:
```
  wget mirror.openshift.com/pub/openshift-v4/clients/ocp/4.5.16/openshift-install-linux-4.5.16.tar.gz

  wget mirror.openshift.com/pub/openshift-v4/clients/ocp/4.5.16/openshift-client-linux-4.5.16.tar.gz
```

* Execute `create_ignition.sh`  This will generate ssh keys, generate install-config.yaml, create a directory based on the cluster name, and create a set of ignition files.
*  Copy the keys to /root/.ssh so that you can ssh (without password) to those VMs. Don't overwrite id_rsa, id_rsa.pub if you already have keys that you care about:

`cp ssh_key /root/.ssh/id_rsa`  
`cp ssh_key.pub /root/.ssh/id_rsa.pub`

At this point you have created a set of configuration files in /home/youhome/$PREFIXTODOMAIN/$IGNITIONDIR

  [6daf02c4]: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/ "Red Hat Download Site"


#### Update DNS:
* On 1st run only:  
  Execute
  `add_dns.sh`

  This will add the content of `NEEDED_DNS_ENTRIES` into `/etc/hosts` and `NEEDED_SVC_ENTRIES` into `/etc/dnsmasq.conf`.  It fails with a `sed -e` error but seems to work anyway.
* On subsequent runs (i.e. after you run `terraform destroy` all):  Change `/etc/hosts` and `/etc/dnsmasq.conf` manually
* restart dnsmasq:
`service dnsmasq restart`    


#### Create the VMs:
- Execute `deploy.sh > main.tf`. This creates the terraform tf

- Run `terraform init`
- Run `terraform apply --auto-approve`

This should complete with:
```
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
```

At this point you have created bootstrap, loadbalancer, 3 master, and 3 worker VMs!  They are powered off.


#### Add custom properties to the VMs
We need to add properties to the VMs which are used for further configuration of the VMs during the installation process.

- Run `vcd.sh`. This will add a "ProductSectionList" containing 2 properties: `guestinfo.ignition.config.data`  information to the VApp Template for each CoreOS VM, and `guestinfo.ignition.config.data.encoding` with a value of `base64`.
It will also add other properties to bootstrap and loadbalancer.
- To verify that vcd.sh worked, run `vcd_get_after_vcd_put.sh` which will GET all the config that vcd.sh POSTed.  The script writes files to /tmp
   - Verify the files in /tmp.  There should be correct ignition data in the Product Section in each CoreOS VApp template. (Hint: run base64 -d on the encoded parts to see what is encoded)

#### Let OpenShift finish the installation:
Once you power on all the VMs there is an intricate dance between all the VMs which results in a completed install. You play a manual role as well by approving pending certificates.

- power on all the VMs in the VAPP.  Alternatively:
- change terraform template to power on the VMs: run `sed -i "s/false/true/" main.tf`
- To power on the VMs run `terraform apply --auto-approve`
- cd to authentication directory: `cd <clusternameDir>/auth`
    This directory contains both the cluster config and the kubeadmin password for UI login
- export KUBECONFIG= clusternameDir/auth/kubeconfig

  Example:   
   `export KUBECONFIG=/root/stuocpvmshared1/stuocpvmshared1.stulipshires.com/auth/kubeconfig`
- Wait until `oc get nodes` shows 3 masters. The workers will not show up until next manual step

`oc get nodes`
```
 NAME                                  STATUS   ROLES    AGE   VERSION
 master-00.ocp44-myprefix.my.com   Ready    master   16m   v1.17.1+6af3663
 master-01.ocp44-myprefix.my.com   Ready    master   16m   v1.17.1+6af3663
 master-02.ocp44-myprefix.my.com   Ready    master   16m   v1.17.1+6af36
```
- Wait until `oc get csr` shows no new 'Pending' Conditions for about 10 mins. This took about 20 mins
- Run `oc get csr --no-headers | awk '{print $1}' | xargs oc adm certificate approve`  to approve the 'Pending' certificates
- Watch to see if other CSRs are in 'Pending' and repeat the approval step
- Watch `oc get co`. Confirm the RH cluster operators are all 'Available'

`oc get co`

```
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
authentication                             4.5.22    True        False         False      79m
cloud-credential                           4.5.22    True        False         False      100m
cluster-autoscaler                         4.5.22    True        False         False      89m
config-operator                            4.5.22    True        False         False      90m
console                                    4.5.22    True        False         False      14m
csi-snapshot-controller                    4.5.22    True        False         False      18m
dns                                        4.5.22    True        False         False      96m
etcd                                       4.5.22    True        False         False      95m
image-registry                             4.5.22    True        False         False      91m
ingress                                    4.5.22    True        False         False      84m
insights                                   4.5.22    True        False         False      90m
kube-apiserver                             4.5.22    True        False         False      95m
kube-controller-manager                    4.5.22    True        False         False      95m
kube-scheduler                             4.5.22    True        False         False      92m
kube-storage-version-migrator              4.5.22    True        False         False      12m
machine-api                                4.5.22    True        False         False      90m
machine-approver                           4.5.22    True        False         False      94m
machine-config                             4.5.22    True        False         False      70m
marketplace                                4.5.22    True        False         False      13m
monitoring                                 4.5.22    True        False         False      16m
network                                    4.5.22    True        False         False      97m
node-tuning                                4.5.22    True        False         False      53m
openshift-apiserver                        4.5.22    True        False         False      12m
openshift-controller-manager               4.5.22    True        False         False      90m
openshift-samples                          4.5.22    True        False         False      53m
operator-lifecycle-manager                 4.5.22    True        False         False      96m
operator-lifecycle-manager-catalog         4.5.22    True        False         False      97m
operator-lifecycle-manager-packageserver   4.5.22    True        False         False      14m
service-ca                                 4.5.22    True        False         False      97m
storage                                    4.5.22    True        False         False      53m

```
#### Configuration to enable OCP console login
- Get the console url by running `oc get routes console -n openshift-console`

`oc get routes console -n openshift-console`
```
 NAME      HOST/PORT                                                  PATH   SERVICES   PORT    TERMINATION          WILDCARD
 console   console-openshift-console.apps.ocp44-myprefix.my.com          console    https   reencrypt/Redirect   None
```

- Create Firewall Rule and DNAT using a Public IP in the Edge Gateway in VCD console. TODO instructions

- Add name resolution to direct console to the Public IP in /etc/hosts on the client that will login to the Console UI.
  As an example:
```
  1.2.3.4 console-openshift-console.apps.ocp44-myprefix.my.com
  1.2.3.4 oauth-openshift.apps.ocp44-myprefix.my.com
```

- From a browser, connect to the "console host" from the `oc get routes` command with https. You will need to accept numerous security warnings as the deployment is using self-signed certificates.


### One last step you must complete in order to ensure the stability of your cluster!
Log in to the Load Balancer form the Bastion   
`ssh core@172.16.0.19`

**Note: In order for this section to work, you need to have v2 (as denoted in the comments) on your machine when it first booted. This requires a version newer than LBOpenshift-0.1 dated 10/06/2020**  

`vi /etc/haproxy/haproxy.cfg`   
and comment out the lines that contain `172.16.0.20`
```
backend 6443
        balance roundrobin
        mode tcp
        server vm0 172.16.0.20:6443 check
        server vm1 172.16.0.21:6443 check
        server vm2 172.16.0.22:6443 check
        server vm3 172.16.0.23:6443 check
backend 22623
        balance roundrobin
        mode tcp
        server vm0 172.16.0.20:22623 check
        server vm1 172.16.0.21:22623 check
        server vm2 172.16.0.22:22623 check
        server vm3 172.16.0.23:22623 check
```
```
backend 6443
        balance roundrobin
        mode tcp
#       server vm0 172.16.0.20:6443 check
        server vm1 172.16.0.21:6443 check
        server vm2 172.16.0.22:6443 check
        server vm3 172.16.0.23:6443 check
backend 22623
        balance roundrobin
        mode tcp
#       server vm0 172.16.0.20:22623 check
        server vm1 172.16.0.21:22623 check
        server vm2 172.16.0.22:22623 check
        server vm3 172.16.0.23:22623 check
```

Save the file and restart the haproxy service.  

`sudo systemctl restart haproxy`

**That's it!  You have an OpenShift Cluster ready to go enjoy!**

## Optional Steps:

- Add an NFS Server to provide Persistent storage. [Here is an article on how to set this up](https://medium.com/faun/openshift-dynamic-nfs-persistent-volume-using-nfs-client-provisioner-fcbb8c9344e). Make the NFS Storage Class the default Storage Class   

`oc patch storageclass managed-nfs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'`

- [Enable the OCP Image registry using your NFS Storage](https://docs.openshift.com/container-platform/4.5/registry/configuring_registry_storage/configuring-registry-storage-baremetal.html)
- [Exposing the Registry](https://docs.openshift.com/container-platform/4.5/registry/securing-exposing-registry.html)


### Reset the environment and redeploy
Its easy to delete the Loadbalancer, Bootstrap, and OpenShift cluster VMs and start over:
```
   terraform destroy --auto-approve        # deletes all the VMs
   mv /home/yourHome/#PREFIXTODOMAIN/ some-backup-dir               # backup everything generated in last run
   mkdir /home/yourHome/#PREFIXTODOMAIN                             # new deployment directory
   cp some-backup-dir/env.sh /home/yourHome/#PREFIXTODOMAIN/        # env.sh contains all the needed configuration
   cp -r some-backup-dir/.terraform//home/yourHome/#PREFIXTODOMAIN/
```
* TODO can we put .terraform (VCD Provider) into /usr/local/openshift/:
* Go back to **Create Ignition files**


### Debug
 * connectivity problems between bastion and other VMs: Temporarily turn off firewall on Bastion.  We have added firewall rules but there may be more "allow" rules needed.

 * To test  HTTP server.  Look at `/usr/local/openshift/env/env.example.com/append-bootstrap.ign` and copy the "source" url.  This is the critical bootstrap-static.ign file that is the primary ignition file
 * get the file:  `wget http://172.16.0.10/usr/local/openshift/env/env.example.com/bootstrap-static.ign`

## Operations
as of now we just power down the VMs which is not a good approach.  We need to adopt better operating procedures. This included **Cluster Recovery** and **outstanding certificate signing requests (CSRs).** See https://www.openshift.com/blog/enabling-openshift-4-clusters-to-stop-and-resume-cluster-vms

## Resources and References

* The overall approach is a  **Bare Metal Install**, also known as UPI - User provisioned Infrastructure, along with static IPs. These 3 RedHat blogs describe the overall approach:
  - [OpenShift 4.1 Bare Metal Install Quickstart](https://www.openshift.com/blog/openshift-4-bare-metal-install-quickstart)
  - [Install with Static IPs](https://www.openshift.com/blog/openshift-4-2-vsphere-install-with-static-ips)
  - [OpenShift 4.2 VSphere Quickstart](https://www.openshift.com/blog/openshift-4-2-vsphere-install-quickstart)
* RedHat doc for **Installing Openshift on VSphere**  https://docs.openshift.com/container-platform/4.5/installing/installing_vsphere/installing-vsphere.html#installation-installing-bare-metal_installing-vsphere
* [**Troubleshooting OpenShift Installations**](https://docs.openshift.com/container-platform/4.5/support/troubleshooting/troubleshooting-installations.html)
* Operating VMware Solutions Shared - Knowledge Center:  https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide
* <a name="about-catalogs">More about Catalogs:</a> https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_vcd-ops-guide#shared_vcd-ops-guide-catalogs
* [**IBM Cloud VMWare Solutions Shared Announcement**](https://www.ibm.com/cloud/blog/announcements/ibm-cloud-for-vmware-solutions-shared-ga)
* [**Getting Started with IBM Cloud VMWare Solutions Shared**](https://www.ibm.com/cloud/blog/3-steps-to-get-started-with-ibm-cloud-for-vmware-solutions-shared)
* interesting article about installing OCP on VMWare: https://medium.com/ibm-garage/an-ocp-4-3-upi-deployment-on-a-vsphere-environment-b0aef0230847
* **Terraform vCloud Director Provider Guide** https://www.terraform.io/docs/providers/vcd/index.html
* [**VMWare Cloud Director Tenant Portal Guide**](https://docs.vmware.com/en/VMware-Cloud-Director/10.1/VMware-Cloud-Director-Tenant-Portal-Guide/GUID-74C9E10D-9197-43B0-B469-126FFBCB5121.html)
* [**VMWare Cloud Director Documentation**](https://docs.vmware.com/en/VMware-Cloud-Director/index.html)
* **ConsulLabs** has a nice approach toward installation, and **GOVC setup** that i'd like to try https://labs.consol.de/container/platform/openshift/2020/01/31/ocp43-installation-vmware.html
* Look at Oren Oichman's **Airgap install, part 2** (then go back to part1):  https://medium.com/@two.oes
* [More about firewalld](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-using_firewalls#sec-Getting_started_with_firewalld)
* [firewall-cmd examples](https://www.thegeekdiary.com/5-useful-examples-of-firewall-cmd-command/)
* TLS handshake timeout - how to debug: https://github.com/openshift/installer/issues/2687
