. ./env_cp4m.sh
KEY=`cat ssh_key.pub|base64 -w0`
BOOTSTRAPDATA=`cat $IGNITIONDIR/append-bootstrap.64`
MASTER0DATA=`cat $IGNITIONDIR/$MASTERNAME-00.64`
MASTER1DATA=`cat $IGNITIONDIR/$MASTERNAME-01.64`
MASTER2DATA=`cat $IGNITIONDIR/$MASTERNAME-02.64`
WORKER0DATA=`cat $IGNITIONDIR/$WORKERNAME-00.64`
STORAGE0DATA=`cat $IGNITIONDIR/$STORAGENAME-00.64`
cat $OPENSHIFT/cp4m/maincp4m.tf.templ | sed -e "s/###VCDUSR###/$VCDUSR/" \
-e "s/###VCDPASS###/$VCDPASS/g" \
-e "s/###VCDCATALOG###/$VCDCATALOG/g" \
-e "s/###VCDURL###/https:\/\/$VCDIP\/api/" \
-e "s/###OSTEMPLATE###/$OSTEMPLATE/g" \
-e "s/###VCDVAPP###/$VCDVAPP/" \
-e "s/###VCDORG###/$VCDORG/g" \
-e "s/###VCDVDC###/$VCDVDC/g" \
-e "s/###VCDNETWORK###/$VCDNETWORK/" \
-e "s/###LBTEMPLATE###/$LBTEMPLATE/" \
-e "s/###LB###/$LB/" \
-e "s/###MASTER0IP###/$MASTER0/"  \
-e "s/###MASTER1IP###/$MASTER1/"  \
-e "s/###MASTER2IP###/$MASTER2/"  \
-e "s/###WORKER0IP###/$WORKER0/"  \
-e "s/###STORAGE0IP###/$WORKER0/"  \
-e "s/###MASTER0FQDN###/$MASTERNAME-00.$DOMAIN/"  \
-e "s/###MASTER1FQDN###/$MASTERNAME-01.$DOMAIN/"  \
-e "s/###MASTER2FQDN###/$MASTERNAME-02.$DOMAIN/"  \
-e "s/###WORKER0FQDN###/$WORKERNAME-00.$DOMAIN/"  \
-e "s/###STORAGE0FQDN###/$WORKERNAME-00.$DOMAIN/"  \
-e "s/###IPADDRESS###/$LB/"  \
-e "s/###NETMASK###/$NETMASK/" \
-e "s/###DNS###/$PUBLICDNS/"  \
-e "s/###GATEWAY###/$GATEWAY/"  \
-e "s/###BOOTSTRAPIP###/$BOOTSTRAP/"  \
-e "s/###SSHKEY###/$KEY/" \
-e "s/###BOOTSTRAPDATA###/$BOOTSTRAPDATA/" \
