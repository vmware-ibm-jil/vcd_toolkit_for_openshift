# vcd_toolkit_for_openshift
1.  Introduction
2.  Prerequisites
3.  Installation of Driver Linux Machine
4.  OpenShift Installation

## Introduction
VMware vCloud Director (“vCD”) is a leading cloud service-delivery platform used by some of the world’s most popular cloud providers to operate and manage successful cloud-service businesses. Using vCloud Director, cloud providers deliver secure, efficient, and elastic cloud resources to thousands of enterprises and IT teams across the world.

Cloud providers utilize vCD to easily create and manage virtual data centers (“VDC”) from common infrastructure to cater to heterogeneous enterprise needs. A policy-driven approach helps ensure enterprises have isolated virtual resources, independent role-based authentication, and fine-grained control.

**User Roles and Personas**

•	Cloud Administrator – cloud provider administrator who owns and operates the provider’s vCD environment

•	Tenant Administrator – vCD Organization user with root privileges (within the Orgnization's vCD environment). Owns and operates Red Hat OpenShift ("OCP) clusters within her vCD Organization.

**Multi-Tenancy Model**

We enable a model where each development team within the enterprise’s IT organization can have its own independent dedicated OCP clusters:

•	Each customer business unit will be mapped to a unique vCD Organization

•	Each vCD Organization includes one or more OrgVDCs

•	Tenant Administrator will be able to provision one or more OCP clusters within each OrgVDC

**Installation Process Overview**

This repository contains artifacts to create OCP clusters on vCD. Once all the required environment variables are populated with valid values, this install process creates ignition files for the deployment and updates the DNS server (see prerequisite below). It then creates the following VMs within the specified vCD Organization/OrgVDC using the Terraform vCloud Director provider.

* Load balancer
* Bootstrap 
* Master-0 
* Master-1
* Master-2
* Worker-0

Once the VMs are deployed, the install process creates custom properties, attaches appropriate ignition files and powers them on. The Bootstrap VM can be shutdown once the environment is configured.

The load balancer VM has HAProxy configured. The HAProxy is configured with IP & port details for the VMs and the HAProxy service is then started.

The overall architecture looks like this:
<p align="center">
<img alt="st-v2" src="Images/Arch.png"/>
</p>

Once the install process is complete, you will have an OCP cluster with a load balancer, three master nodes and one worker node. The install process also updates DNS entries in Dnsmasq as well as port forwarding in the load balancer.

## Prerequisites

* Access to vCD environment with vCD Organization admin user privileges
* Driver Linux Machine accessible from all VMs which needed to be configured as part of the OCP installation
* Dnsmasq configured as DNS server on Driver Linux Machine
*	Accessible DHCP server on vCD Organization network
*	At least 6 IP addresses on the vCD Organization network (additional IP addresses are required if you wish to have additional worker nodes in the OCP cluster)
*	VM template for OCP
* VM template for load balancer
*	Valid Red Hat pull-secret which will be specified in OCP configuration file

## Installation of Driver Linux Machine

The Driver Linux Machine hosts the installation toolkit and serves as DNS server for the environment. It also hosts the HTTP server through which ignition files are provided to the bootstrap machine at boot time.

 * Install and configure Ubuntu 16.04 (any version should work)
 
 * Install Dnsmasq by running “apt-get install dnsmasq”. Dnsmasq provides both DNS and DHCP services. If desired, DHCP service can be turned off by adding the following entry for each interface: no-dhcp-interface=ens192
 
 * If the OCP installation is not performed as root user, add  following line to end of the file /etc/sudoers "<user_name>  ALL=(ALL:ALL) NOPASSWD: ALL"
 
 * Restart DNS service by running "service dnsmasq restart"
 
 * Put dummy-host entry into /etc/host and verify DNS resolution by executing the command "nslookup <dummy-host> <dns-ip-address>" from other hosts and verify that it returns IP address associated with dummy-host
  
 * Execute following command as root user - "cd /; python -m SimpleHTTPServer 80". Depending on version of Python, command syntax may need to be adjusted
 
 * Execute following command as root user - "tar -xvf vcd_toolkit_for_openshift4.tar". This will create a directory under /usr/local which contains all utilities required to install and configure the OCP environment.

## OpenShift Installation

This section details steps required to configure the OCP environment.

* Login as a user with sudo privileges into the Driver Linux Machine you configured previously
* Excute "mkdir uniq-directory-name; cd unique-directory-name" to host the OCP environment's files you are about to create
* Execut "cp /usr/local/openshift/env.sh.template env.sh"
* Edit env.sh to specify the required environment properties
  
  **Networking-related Parameters**
   - DHCP=no -- This is for future use and only option that currently is set to no
   - HTTPIP=###HTTPIP### -- This is the HTTP Server IP which renders HTTP file. This is the IP of Ubuntu machine configured as a driver machine in previous section. The http server was started on this machine as described in previous section.
   - HTTPPORT=80 -- The port on which HTTP server listen to.  
   - BOOTSTRAP -- Static IP address which will be assigned to bootstrap machine. 
   - MASTER0 -- Static IP address which will be assigned to first master  machine. 
   - MASTER1 -- Static IP address which will be assigned to second  master  machine. 
   - MASTER2 -- Static IP address which will be assigned to third master  machine. 
   - WORKER0 -- Static IP address which will be assigned to first worker  machine. 
   - NETMASK -- Netmask associated with the network on which above IP addresses were assgined to
   - GATEWAY -- Gateway address associated with network on which above IP addreses were assigned to 
  
  **OCP-related Parameters**
   - OPENSHIFT=/usr/local/openshift  -- Location of vcd toolkit for OpenShift
   - FILETRANSPILER=$OPENSHIFT/filetranspiler/filetranspile -- Location of FILETRANSPILER the program which updates ignition with static ip
   - MASTERNAME  prefix of name of the master machine -- cannot be changed, has to be master
   - WORKERNAME -- prefix of name of the worker machine -- cannot be changed, has to be worker
   - BASEDOMAIN --  name of the base domain
   - PREFIXTODOMAIN -- name of the prfix which will be preneded to the base
   - SERVICENETWORK -- service natowork i.e., 172.31.0.0
   - SERVICENETWORKCIDR -- CIDR for above network 16 is recommended
   - PULLSECRET -- location of pull secret file downloaded from Redhat portal for given registered supported Redhat user.
   - OSENVID -- OpenShift ENV ID -- no change necessary
   - HTTPIGNPATH -- Path to bootstrap ignition file -- no change needed
   - DNSPOPULATE -- yes/no -- for dnsmasq yes is the default value. 
   - DNSMASQCONF -- location of the dnsmasq file -- no change needed
   
  **Terraform/vCD-related Parameters**
   - TERRAFORMID -- No change needed
   - VCDVAPP -- name of vapp which contains all vms associated with OpenShift
   - VCDVAPP -- No change needed 
   - VCDORG -- organisation name for vcd under which the OpenShift environment vm's will be deployed
   - VCDUSR -- VCD Org user who either has admin privilleges or ability  to create vm and associate resoruces with
   - VCDPASS -- password of above user
   - VCDNETWORK -- Organisation Network to which all vm will be associated with
   - VCDIP -- VCD IP or fqdn
   - VCDVDC -- virtual datacenter name for vcd under which the OpenShift environment vm's will be deployed
   - VCDCATALOG -- name of the catalogue where OpenShift template and LoadBalacer template can be located
   - OSTEMPLATE -- name of the OpenShift template
   - LBTEMPLATE -- name of the LoadBalancer template. 
   
 * **Create OpenShift Environment**

   Following steps can be put into a shell script if desired.
   
    - Execute "cd unique-directory-name" -- the directory where env.sh file is located
    - Execute "PATH=$PATH:/usr/local/openshift;export PATH"
    - Execute "create_ignition.sh"
    - Execute "add_dns.sh"
    - Execute "deploy.sh > main.tf"
    - Execute "terraform init"
    - Execute "terraform apply --auto-approve"
    - Execute "vcd.sh"
    - Execute "sed -i "s/false/true/" main.tf"
    - Execute "terraform apply --auto-approve" 
   
