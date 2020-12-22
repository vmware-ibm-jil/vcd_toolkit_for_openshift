## Introduction
These files are placed  on the haproxy server to customize the `haproxy.cfg` file to load balance.

rc.local will only execute on firstboot (determined by the presence of /boot/firstboot)

rc.local must be placed in the /etc directory on the server
`haproxy.cfg.template` must be placed in the `/etc/haproxy`

If you modify rc.local to add nodes, you currently need to change the template file too.

_TODO: should either be changed to just generate the file based on the worker nodes or switch to vmware LB and forget about the proxy node_

If you make changes to `rc.local` and `haproxy.cfg.template`, you will need to add `/boot/firstboot` by executing:  

 `touch /boot/firstboot`  
 `chmod 777 /boot/firstboot`  
 `groupdel lbadmin`  

  and then saving a new version of the VMWare template for this server in the Public catalog
