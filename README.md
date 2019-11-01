# vcd_toolkit_for_openshift
1.  [Introduction](#introduction)
2.  [Prerequisites](#Prerequisites)
3.  [Installation](#installation)
## Introduction
The VCD Toolkit for OpenShift contains required articats to create OpenShift environment on vCloud Director. This tookit creates following virtual machines on the org/orgvdc. 
Loadbalancer
Bootstrap 
Master-0 
Master-1
Master-2
Worker-0

The overall architecture looks like this:
<p align="center">
<img alt="st-v2" src="Images/Arch.png"/>
</p>

## Prerequisites
* vCloud Director
* Driver Linux machine accessible from all VM which will be configured as part of OpenShift installation.
* DNSMASQ configured as DNS server on Driver machine
* Accessible DHCP server on organisation network 
* At least 6 IP address on this organisation network (In future extra IP will be needed as worker node added)

