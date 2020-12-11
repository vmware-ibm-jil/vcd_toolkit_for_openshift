. ./env.sh
mkdir -p $IGNITIONDIR
rm -rf ssh_key ssh_key.pub
rm -rf $IGNITIONDIR/*.ign  $IGNITIONDIR/*.64 $IGNITIONDIR/auth $IGNITIONDIR/*.yaml $IGNITIONDIR/NEEDED_DNS_ENTRIES  $IGNITIONDIR/NEEDED_SRV_ENTRIES
ssh-keygen -t rsa -b 4096 -N ''     -f ssh_key
cat $OPENSHIFT/install-config.yaml.templ| sed -e "s/BASEDOMAIN/$BASEDOMAIN/" -e "s/WORKER/$WORKERNAME/" -e "s/MASTER/$MASTERNAME/" -e "s/PREFIXDOMAIN/$PREFIXTODOMAIN/" -e "s/SERVICENETWORK/$SERVICENETWORK\/$SERVICENETWORKCIDR/" > $IGNITIONDIR/install-config.yaml
echo "pullSecret: '`cat $PULLSECRET`'" >> $IGNITIONDIR/install-config.yaml
echo "sshkey: '`cat ssh_key.pub`'" >> $IGNITIONDIR/install-config.yaml
cp $IGNITIONDIR/install-config.yaml .
$OPENSHIFT/openshift-install create ignition-configs --dir=$IGNITIONDIR
mkdir -p $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/
#######BOOTSTRAP STATIC IP
echo bootstrap.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$BOOTSTRAP/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i bootstrap.ign  -f bootstrap -o bootstrap-static.ign
cd ..
#######

#######MASTER00 STATIC IP
echo $MASTERNAME-00.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$MASTER0/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i master.ign  -f bootstrap -o $MASTERNAME-00-static.ign

cd ..
#######

########MASTER01 STATIC IP
echo $MASTERNAME-01.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$MASTER1/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i master.ign  -f bootstrap -o $MASTERNAME-01-static.ign
cd ..
#######

########MASTER02 STATIC IP
echo $MASTERNAME-02.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$MASTER2/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i master.ign  -f bootstrap -o $MASTERNAME-02-static.ign
cd ..
#######
#
#
#
########WORKER0 STATIC IP
echo $WORKERNAME-00.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$WORKER0/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i worker.ign  -f bootstrap -o $WORKERNAME-00-static.ign
cd ..
#######################
########WORKER1 STATIC IP
echo $WORKERNAME-01.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$WORKER1/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i worker.ign  -f bootstrap -o $WORKERNAME-01-static.ign
cd ..
#######################
########WORKER2 STATIC IP
echo $WORKERNAME-02.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$WORKER2/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i worker.ign  -f bootstrap -o $WORKERNAME-02-static.ign
cd ..
########STORAGE0 STATIC IP
echo $STORAGENAME-00.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$STORAGE0/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i worker.ign  -f bootstrap -o $STORAGENAME-00-static.ign
cd ..
########STORAGE1 STATIC IP
echo $STORAGENAME-01.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$STORAGE1/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i worker.ign  -f bootstrap -o $STORAGENAME-01-static.ign
cd ..
########STORAGE2 STATIC IP
echo $STORAGENAME-02.$DOMAIN > $IGNITIONDIR/bootstrap/etc/hostname
cat  $OPENSHIFT/ens192.templ | sed -e "s/IPADDR1/$STORAGE2/" -e "s/NETMASK1/$NETMASK/" -e "s/GATEWAY1/$GATEWAY/" -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS11/$DNS/"  -e "s/DOMAIN1/$DOMAIN/" -e "s/DNS22/$PUBLICDNS/" >  $IGNITIONDIR/bootstrap/etc/sysconfig/network-scripts/ifcfg-ens192
cd $IGNITIONDIR
$FILETRANSPILER -i worker.ign  -f bootstrap -o $STORAGENAME-00-static.ign
cd ..
#######################
HTTPURL=http://$HTTPIP`pwd`/$IGNITIONDIR/bootstrap-static.ign
HTTPURL=http://$HTTPIP`pwd`/$IGNITIONDIR/bootstrap-static.ign
HTTPURL=http://$HTTPIP`pwd`/$IGNITIONDIR/bootstrap-static.ign
######################
##### CONFIGURE HTTPURL AND BASE64
cd $IGNITIONDIR
cat $OPENSHIFT/append-bootstrap.ign | sed  -e "s!HTTPURL!$HTTPURL!" > append-bootstrap.ign
base64 -w0 append-bootstrap.ign > append-bootstrap.64
base64 -w0 $MASTERNAME-00-static.ign >  $MASTERNAME-00.64
base64 -w0 $MASTERNAME-01-static.ign >  $MASTERNAME-01.64
base64 -w0 $MASTERNAME-02-static.ign >  $MASTERNAME-02.64
base64 -w0 $WORKERNAME-00-static.ign >  $WORKERNAME-00.64
base64 -w0 $WORKERNAME-01-static.ign >  $WORKERNAME-01.64
base64 -w0 $WORKERNAME-02-static.ign >  $WORKERNAME-02.64
base64 -w0 $STORAGENAME-00-static.ign >  $STORAGENAME-00.64
base64 -w0 $STORAGENAME-01-static.ign >  $STORAGENAME-01.64
base64 -w0 $STORAGENAME-02-static.ign >  $STORAGENAME-02.64

cd ..

########### CONFIGURE NEEDED DNS ENTRIES
#
echo   $LB api-int.$DOMAIN >$IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $LB api.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $BOOTSTRAP bootstrap.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $MASTER0 $MASTERNAME-00.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $MASTER0 etcd-0.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $MASTER1 $MASTERNAME-01.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $MASTER1 etcd-1.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $MASTER2 $MASTERNAME-02.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $MASTER2 etcd-2.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $WORKER0 $WORKERNAME-00.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $WORKER1 $WORKERNAME-01.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $WORKER2 $WORKERNAME-02.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $STORAGE0 $STORAGENAME-00.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $STORAGE1 $STORAGENAME-01.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
echo   $STORAGE2 $STORAGENAME-02.$DOMAIN >> $IGNITIONDIR/NEEDED_DNS_ENTRIES
sed -e "s/###DOMAIN###/$DOMAIN/g" -e "s/###LB###/$LB/g" $OPENSHIFT/srv_entry.templ >> $IGNITIONDIR/NEEDED_SRV_ENTRIES
