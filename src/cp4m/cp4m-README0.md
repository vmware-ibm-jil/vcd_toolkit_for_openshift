## Introduction
Experimental code may not work completely yet

## To use code
Execute
`add_dns_cp4m.sh` instead of `add_dns.sh`

Execute `create_ignition_cp4m.sh` instead of `create_ignition.sh`  

Execute `deploy_cp4m.sh > main.tf` instead of `deploy.sh > main.tf`

For right now, you will need to copy this file the loadbalancer to replace existing /etc/haproxy/haproxy.cfg.
You will need to do this starting the loadbalancer after you have run `vcd_cp4m.sh`. You need to do this in the following sequence.
1. After all vm's have been created via terraform apply, go to VMWare console and start ONLY the loadbalancer. It will start and then reboot itself. Wait for the reboot. 


Execute `vcd_cp4m.sh` instead of `vcd.sh`
