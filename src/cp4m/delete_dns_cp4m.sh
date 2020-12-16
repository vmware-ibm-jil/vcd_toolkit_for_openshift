. ./env_cp4m.sh
DNSMASQCONF=/etc/dnsmasq.conf
DNSPOPULATE=yes
if [ "$DNSPOPULATE" = "yes" ]
then
    echo "ABOUT TO UPDATE HOSTS"
    cp /etc/hosts /etc/hosts.before.`echo $DOMAIN`.deleted
    while read -r line; do sed  -i "/$line/d" /etc/hosts ;done < $IGNITIONDIR/NEEDED_DNS_ENTRIES
    while read -r line; do sed  -i "/$line/d" $DNSMASQCONF ;done < $IGNITIONDIR/NEEDED_SRV_ENTRIES
    sed -i "/apps.$DOMAIN/d" $DNSMASQCONF
    service dnsmasq restart
fi
