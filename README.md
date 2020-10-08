## Introduction
The vcd_toolkit_for-openshift is a set of scripts, VM Templates, and instructions which allow you to quickly deploy RedHat OpenShift into a VMware Cloud Director environment.

VMware Cloud Director (“VCD”) is a leading cloud service-delivery platform used by some of the world’s most popular cloud providers to operate and manage successful cloud-service businesses. Using VCD, cloud providers deliver secure, efficient, and elastic cloud resources to thousands of enterprises and IT teams across the world.

Cloud providers utilize VCD to easily create and manage virtual data centers (“VDC”) from common infrastructure to cater to heterogeneous enterprise needs. A policy-driven approach helps ensure enterprises have isolated virtual resources, independent role-based authentication, and fine-grained control.

The vcd_toolkit_for_openshift was developed and tested on IBM Cloud VMWare Solution Shared which is based on VCD.   The detailed instructions provided below allow you to quickly deploy OpenShift clusters on IBM Cloud.

**User Roles and Personas**

* Cloud Administrator – cloud provider administrator who owns and operates the provider’s VCD environment

* Tenant Administrator – VCD Organization user with root privileges (within the Orgnization's VCD environment). Owns and operates Red Hat OpenShift ("OCP) clusters within their VCD Organization.

**Multi-Tenancy Model**

The toolkit enables a model where each development team within the enterprise’s IT organization can have its own independent dedicated OCP clusters:

* Each customer business unit will be mapped to a unique VCD Organization

* Each VCD Organization includes one or more Org VDCs

* Tenant Administrator will be able to provision one or more OCP clusters within each Org VDC

**Installation Process Overview**

The installation process is driven from a VM we call Bastion, which is in the same network as the VMs that it will provision.  To get started you will clone the vcd_toolkit_for_openshift into the Bastion VM.
The repo contains artifacts needed to create OCP clusters on VCD. Once all the required environment variables are populated, the VCD Toolkit for OpenShift install process creates ignition files for the deployment and updates the DNS server (see prerequisite below). It then creates the following VMs within the specified VCD Organization/OrgVDC using the Terraform vCloud Director provider.

* Load balancer
* Bootstrap 
* Master-0 
* Master-1
* Master-2
* Worker-0
* Worker-1
* Worker-2

Once the VMs are deployed, the install process creates VM custom properties, attaches appropriate ignition files, and powers them on. The Bootstrap VM can be shutdown once the environment is configured.

The load balancer VM has HAProxy configured. The HAProxy is configured with IP & port details for the VMs and the HAProxy service is then started.

The overall architecture looks like this:
<p align="center">
<img alt="st-v2" src="Images/Arch.png"/>
</p>

Once the install process is complete, you will have an OCP cluster with a load balancer, three master nodes and three worker nodes. The install process also updates DNS entries in Dnsmasq as well as port forwarding in the load balancer.

Detailed installation instructions are available [here in the doc folder](doc/ibm-cloud-vss.md)
