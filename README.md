# vcd_toolkit_for_openshift
1.  [Introduction](#introduction)
2.  [Prerequisites](#Prerequisites)
3.  [Toolkit Installation](#installation)
4.  [OpenShift Installation(#OpenShift Installation)

## Introduction
The VCD Toolkit for OpenShift contains required articats to create OpenShift environment on vCloud Director. This tookit, once all the environment variables populated with valid values, create ignition file for the deployemnt, updates the DNS server (See prerequisite below). The toolkit then creates following virtual machines on the org/orgvdc using Terraform.

Loadbalancer
Bootstrap 
Master-0 
Master-1
Master-2
Worker-0

Once the vms are deployed the toolkit applies the customer properties and attaching the appropriate ignition files to vms and powers them on. The bootstrap machin can be shutdown once the environment is configured.

The overall architecture looks like this:
<p align="center">
<img alt="st-v2" src="Images/Arch.png"/>
</p>

## Prerequisites
* Access to vCloud Director with org. admin user
* Driver Linux machine accessible from all VM which will be configured as part of OpenShift installation.
* DNSMASQ configured as DNS server on Driver machine
* Accessible DHCP server on organisation network 
* At least 6 IP address on this organisation network (In future extra IP will be needed as worker node added)
* Openshift template for vcenter is available from catalogue
* LoadBalaner template is available from the catalogue
* Vaid user on Redhat wich contains pull-secreat which will be passed to OpenShift ignition file.

## Insallaion
<b>
  <font size="+2">
Driver/DNS/HTTP Server Ubuntu 16.04 Linux machine configuration:
  </font>
</b>

 The Ubuntu Linux machine which will host tookit will also act as DNS server for the OpenShift environment. This machine will also start the http server through which ignition file can be rendered to bootstrap machine at the time of boot.

 * Install and configure Ubuntu 16.04 (Any version works but tested with 16.04)
 * “apt-get install dnsmasq”   will install dnsmasq on the previously configure Ubuntu vm
 * dnsmasq provides both DNS and DHCP services. DHCP service can be turned off putting following entry for each interface:

   no-dhcp-interface=ens192
  
 * If the execution of OpenShift installation is not done by root user, at the <b>end of the file /etc/sudoers </b>"<user_name>  ALL=(ALL:ALL) NOPASSWD: ALL" 
 * restart dns service with "service  dnsmasq restart"
 * Put dummy host entry into /etc/host and from other machine execute the command "nslookup <dummy-host> <dns-ip-address>" and verify that it returns the ipaddress associated with dummy-host
 * As a root user go to execute following command - "cd /; python -m SimpleHTTPServer 80". Depending on python version the command syntax needs to be adjusted. 
 * As a root user execute "tar -xvf vcd_toolkit_for_openshift4.tar". It will create openshift directory under /usr/local which contains needed utility to install and configure openshift environment.

## OpenShift Installation

This section describes the steps needed to configure the OpenShit environment.

* Login as a user with sudo privilleges into Ubutu linux machine you configured in previos section
* Excute "mkdir <uniq-directory-name>; cd<unique-directory-name>". This directory contains the unique OpenShift environment you are about to create.
* Execut "cp /usr/local/openshift/env.sh.template env.sh"
  Modifyt all the parameters very carefully
  DHCP=no -- This is for future use and only option at currently is no
   - HTTPIP=###HTTPIP### -- This is the HTTP Server IP which renders HTTP file. This is the IP of Ubuntu machine configured as a driver machine in previous section. The http server was started on this machine as described in previous section
  
  



