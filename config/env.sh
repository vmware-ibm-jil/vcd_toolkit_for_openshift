####### Environment Variables used by vcd_toolkit #################################################3
#
# The default values configured below will work in most cases.
#
# Variable that must be changed, or are reccomended to change, have "CHANGEME" in the comments 
#  
###################################################################################################


#========================================================================================================
# Standard bastion and networking variables. You don't need to change.  The default values will work
#
# The installation driver VM (named bastion) is 172.16.0.10 by default
HTTPIP=172.16.0.10    # HTTP server on bastion VM where the extended ignition file for bootstrap VM will be retrieved from
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
PUBLICDNS=172.16.0.10     # This MUST be bastion VM ip address, same as DNS variable above.  Bastion MUST be configured to forward requests it cannot resolve to a public DNS server.


#=================================================================================================
# OpenShift and  vcd_toolkit / install-config.yaml related parameters.  Default values will work
#
OPENSHIFT=/usr/local/openshift                          # location of the VCD Toolkit for OpenShift scripts and binaries
FILETRANSPILER=$OPENSHIFT/filetranspiler/filetranspile  # Filetranspiler is the program which updates ignition with static IP addresses
SERVICENETWORK=172.30.0.0        # private internal OpenShift network. Not the same network as 172.16.0.0/24. It is also not the IBM Cloud Service network.
SERVICENETWORKCIDR=16            # Netmask for SERVICENETWORK
MASTERNAME=master                  # prefix of master VM names.  Must be "master". fqdn will be, for example, master-00.<PREFIXTODOMAIN>.<BASDDOMAIN>
WORKERNAME=worker                  # prefix of worker VM names.  Must be "worker". fqdn will be, for example, worker-00.<PREFIXTODOMAIN>.<BASDDOMAIN>


#=================================================================================================
PULLSECRET=/tmp/pull-secret.txt    # CHANGEME. file location of pull secret downloaded From RedHat for the supported user running the scripts


#=================================================================================================
# Local environment where the deployment is driven from 
BASEDOMAIN=my.com                  # CHANGEME (default will work though). Domain to use for all cluster nodes
PREFIXTODOMAIN=myprefix            # CHANGEME (default will work though). Prefix which will be prepended to BASEDOMAIN. Lower case alfa-num only.  This will also be the directory where we will deploy from. For example /home/<user>/$PREFIXTODOMAIN/

DOMAIN=$PREFIXTODOMAIN.$BASEDOMAIN                            # Do not update. For example myprefix.my.com. Lower case alfa-num only. This will also be the directory on bastion where deployment artifacts are generated to
IGNITIONDIR=$PREFIXTODOMAIN.$BASEDOMAIN                       # Do not update. Directory where ignition files will be generated to
OSENVID=`echo $PREFIXTODOMAIN.$BASEDOMAIN|sed -e 's/\./-/g'`  # Do not update.  i.e "myprefix-my-com".  see also TERRAFORMID and VCDVAPP
HTTPIGNPATH=`pwd`/$IGNITIONDIR/bootstrap-static.ign           # Do not update.
DNSPOPULATE=yes                                               # tells script to populate local DNS /etc/hosts or not (yes|no)
CREATESSHKEYS=yes                                             # tells script to create new ssh keys yes/no, no will reuse keys
DNSMASQCONF=/etc/dnsmasq.conf                                 # Do not update. location of dnsmasq.conf on bastion


#=================================================================================================
# VCD Toolkit Terraform related parameters 
TERRAFORMID=`echo $OSENVID | sed -e 's/\./-/g'` # Do not update. TODO don't need the sed? just use OSENVID
VCDVAPP=`echo $OSENVID | sed -e 's/\./-/g'`     # Do not update. TODO don't need the sed? uust use OSENVID

VCDORG=really-long-alfa-num-string              # CHANGEME. VCD organization. Found on the VCD console, Data Centers tab
VCDUSR=adminUser                                # CHANGEME. VCD org admin user
VCDPASS=adminPw                                 # CHANGEME. VCD password for above user
VCDVDC="myVDC"                                  # CHANGEME. VCD ORG Virtual Data Center name. Whatever you want.

VCDNETWORK=ocpnet                               # name of VCD network where OCP VMs will be deployed
VCDIP=daldir01.vmware-solutions.cloud.ibm.com   # CHANGEME.(default may be correct for your environment).  This is the FQDN where your VCD instance resides.  Found on the VCD Console, Data Centers tab (this is NOT an IP address)
VCDCATALOG='Public Catalog'                     # catalog where following two items are located. "Public Cloud" is the catalog name in IBM Cloud VMWare Solution Shared.
OSTEMPLATE='rhcos OpenShift 4.5.6'              # CHANGEME. only change if you want to install OCP 4.4, or if you have your own template in your own catalog
LBTEMPLATE='lbopenshiftv2'                      # name of load balancer template
