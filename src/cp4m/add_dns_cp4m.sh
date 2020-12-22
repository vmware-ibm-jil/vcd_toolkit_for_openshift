. ./env_cp4m.sh
DNSMASQCONF=/etc/dnsmasq.conf
if [ "$DNSPOPULATE" = "yes" ]
then
  echo "ABOUT TO UPDATE HOSTS"
  cp /etc/hosts /etc/hosts.before.`echo $DOMAIN`
    while read -r line; do sed  -i "/$line/d" /etc/hosts ;done < $IGNITIONDIR/NEEDED_DNS_ENTRIES
    while read -r line; do sed  -i "/$line/d" $DNSMASQCONF ;done < $IGNITIONDIR/NEEDED_SRV_ENTRIES
    sed -i "/apps.$DOMAIN/d" $DNSMASQCONF
  cat $IGNITIONDIR/NEEDED_DNS_ENTRIES >> /etc/hosts
  cat $IGNITIONDIR/NEEDED_SRV_ENTRIES >> /etc/dnsmasq.conf
  service dnsmasq restart
fi
. ./env.sh
DNSMASQCONF=/etc/dnsmasq.conf
DNSPOPULATE=yes
if [ "$DNSPOPULATE" = "yes" ]
then
    echo "ABOUT TO UPDATE HOSTS"
    cp /etc/hosts /etc/hosts.before.`echo $DOMAIN`.deleted
    service dnsmasq restart
fi
