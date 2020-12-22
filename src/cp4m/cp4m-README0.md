## Introduction
## Experimental code may not work completely yet!!

Execute `PATH=$PATH:/usr/local/openshift:/usr/local/openshift/cp4m; export PATH`

`cp this-repo/config/env_cp4m.sh /home/yourHome/$PREFIXTODOMAIN`

Modify `env_cp4m.sh` instead of `env.sh`

## To use code
Execute
`add_dns_cp4m.sh` instead of `add_dns.sh`

Execute `create_ignition_cp4m.sh` instead of `create_ignition.sh`  

Execute `deploy_cp4m.sh > main.tf` instead of `deploy.sh > main.tf`

For right now, you will need to copy this file the loadbalancer to replace existing /etc/haproxy/haproxy.cfg.
You will need to do this starting the loadbalancer after you have run `vcd_cp4m.sh`. You need to do this in the following sequence.
After all vm's have been created via terraform apply, go to VMWare console and start ONLY the loadbalancer. It will start and then reboot itself. Wait for the reboot.

1. `cd ~/vcd_toolkit_for_openshift/haproxyfiles/`
2. `sftp core@172.16.0.19`
3. `put haproxy.cfg.cp4m /etc/haproxy/haproxy.cfg`
4. `quit`
5. `ssh core@172.16.0.19`
6. `sudo systemctl restart haproxy`
7. `exit`

Now start the rest of your VM's as usual


Execute `vcd_cp4m.sh` instead of `vcd.sh`
