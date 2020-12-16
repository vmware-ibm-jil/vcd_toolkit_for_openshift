####### Set the following Environment Variables:
#
# our installation driver VM (called bastion) will also host HTTP Server (for ignition files) and local DNS resolver:
HTTPIP=172.16.0.10    # HTTP server on bastion VM where the ignition files will be retrieved from
DNS=172.16.0.10       # the local DNS resolver (DNSMasq) on bastion
HTTPPORT=80           # HTTP server port the ignition files will be retrieved from

LB=172.16.0.19        # static IP where loadbalancer will be deployed
BOOTSTRAP=172.16.0.20 # static IP of bootstrap VM
MASTER0=172.16.0.21   # static IP of master0 VM
MASTER1=172.16.0.22   # static IP of master1 VM
MASTER2=172.16.0.23   # static IP of master2 VM
WORKER0=172.16.0.24   # static IP of worker VM
WORKER1=172.16.0.25   # static IP of worker VM
WORKER2=172.16.0.26   # STATIC IP of worker VM
NETMASK=255.255.255.0 # /24 netmask for all above IP
GATEWAY=172.16.0.1    # getway of network for all above IP
PUBLICDNS=172.16.0.10     # DNS where PUBLIC names can be resolved

#======== OpenShift and  install-config.yaml related parameters ==========
OPENSHIFT=/usr/local/openshift                          # location of the VCD Toolkit for OpenShift scripts and binaries
FILETRANSPILER=$OPENSHIFT/filetranspiler/filetranspile  # Filetranspiler is the program which updates ignition with static IP addresses
SERVICENETWORK=172.30.0.0        # private internal OpenShift network. Not the same network as 172.16.0.0/24. It is also not the IBM Cloud Service network.
SERVICENETWORKCIDR=16            # Netmask for SERVICENETWORK
PULLSECRET=/tmp/pull-secret.txt  # file location of pull secret downloaded From RedHat for the supported user running the scripts

#======== Local environment where the deployment is driven from ==========
BASEDOMAIN=my.com                  # domain to use for all cluster nodes
PREFIXTODOMAIN=myprefix            # prefix which will be prepended to BASEDOMAIN. Lower case alfa-num only.  This will also be the directory where we will deploy from. For example /home/<user>/$PREFIXTODOMAIN/
DOMAIN=$PREFIXTODOMAIN.$BASEDOMAIN # for example myprefix.my.com. Lower case alfa-num only. This will also be the directory where deployment artifacts are generated to
MASTERNAME=master                  # prefix of master VM names.  Must be "master". fqdn will be, for example, master-00.<PREFIXTODOMAIN>.<BASDDOMAIN>
WORKERNAME=worker                  # prefix of worker VM names.  Must be "worker". fqdn will be, for example, worker-00.<PREFIXTODOMAIN>.<BASDDOMAIN>
IGNITIONDIR=$PREFIXTODOMAIN.$BASEDOMAIN # directory where ignition files will be generated to
OSENVID=`echo $PREFIXTODOMAIN.$BASEDOMAIN|sed -e 's/\./-/g'`  # Do not update.  i.e "myprefix-my-com".  see also TERRAFORMID and VCDVAPP
HTTPIGNPATH=`pwd`/$IGNITIONDIR/bootstrap-static.ign           # Do not update.
DNSPOPULATE=yes                # tells script to populate local DNS /etc/hosts or not (yes|no)
CREATESSHKEYS=yes               #tells script to create new ssh keys yes/no, no will reuse keys
DNSMASQCONF=/etc/dnsmasq.conf  # location of dnsmasq.conf

#======== VCD Toolkit Terraform related parameters ========
TERRAFORMID=`echo $OSENVID | sed -e 's/\./-/g'` # Do not update. TODO don't need the sed? just use OSENVID
VCDVAPP=`echo $OSENVID | sed -e 's/\./-/g'`     # Do not update. TODO don't need the sed? uust use OSENVID
VCDORG=really-long-alfa-num-string              # VCD organization. Found on the VCD console, Data Centers tab
VCDUSR=adminUser                                # VCD org admin user
VCDPASS=adminPw                                 # VCD password for above user
VCDNETWORK=ocpnet                               # name of VCD network where OCP VMs will be deployed
VCDIP=daldir01.vmware-solutions.cloud.ibm.com   # fqdn where you VCD instance resides.  Found on the VCD Console, Data Centers tab (this is NOT an IP address)
VCDVDC="myVDC"                                  # VCD ORG Virtual Data Center name. Whatever you want.
VCDCATALOG='Public Catalog'                     # catalog where following two items are located. "Public Cloud" is the catalog name in IBM Cloud VMWare Solution Shared.
OSTEMPLATE='rhcos OpenShift 4.5.6'              # name of openshift template
LBTEMPLATE='lbopenshiftv2'                   # name of load balancer template
