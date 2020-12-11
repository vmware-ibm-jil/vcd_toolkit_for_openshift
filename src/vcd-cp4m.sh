. ./env.sh
echo $OSENVID
VMLIST=vmlist
VMLIST1=vmlist1
rm -f $VMLIST $VMLIST1
auth=`curl -i -k -H "Accept:application/*+xml;version=31.0" -u $VCDUSR@$VCDORG:$VCDPASS -X POST https://$VCDIP/api/sessions|grep x-vcloud-authorization|awk '{print $2}'|sed -e "s/\r//"`

echo "#####$auth#####"

vapp_url=`curl -i -k -H "Accept:application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -X GET "https://$VCDIP/api/query?type=vApp&filter=name==$OSENVID"|grep VAppRecord| awk 'BEGIN{RS="href=\""} {print $1}'|cut  -d\" -f1|tail -1||sed -e "s/\r//"`

echo $vapp_url
curl -i -k -H "Accept:application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -X GET  $vapp_url > $VMLIST
for j in `cat $VMLIST | grep "Vm needsCustomization="`
 do
k=AAA
case "$j" in
href*) k=`echo $j|cut -d\" -f2`;;
esac
if [ "$k" != "AAA" ]
then
echo $k >> $VMLIST1
fi
done



for i in `cat $VMLIST1`
  do
  grep $i $VMLIST|grep bootstrap > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo bootstrap FOUND
    echo $i
    cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
    a=`cat $IGNITIONDIR/append-bootstrap.64`
    sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
    mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/bootstrap.custom_property.xml
    fi

  grep $i $VMLIST|grep master-0 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo master-0 FOUND
    echo $i
    cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
    a=`cat $IGNITIONDIR/$MASTERNAME-00.64`
    sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
    mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/master-0.custom_property.xml
    fi

  grep $i $VMLIST|grep master-1 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo master-1 FOUND
    echo $i
    cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
    a=`cat $IGNITIONDIR/$MASTERNAME-01.64`
    sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/master-1.custom_property.xml
    fi

  grep $i $VMLIST|grep master-2 > /dev/null 2>&1
  if [ $? = 0 ]
    then
     echo master-2 FOUND
     cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
     a=`cat $IGNITIONDIR/$MASTERNAME-02.64`
     sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
     curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
     echo $i
mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/master-2.custom_property.xml
  fi

  grep $i $VMLIST|grep worker-0 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo worker-0 FOUND
    cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
    a=`cat $IGNITIONDIR/$WORKERNAME-00.64`
    sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
    echo $i
mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/worker-0.custom_property.xml
    fi

    grep $i $VMLIST|grep worker-1 > /dev/null 2>&1
    if [ $? = 0 ]
      then
      echo worker-1 FOUND
      cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
      a=`cat $IGNITIONDIR/$WORKERNAME-01.64`
      sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
      curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
      echo $i
  mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/worker-1.custom_property.xml
      fi

    grep $i $VMLIST|grep worker-2 > /dev/null 2>&1
    if [ $? = 0 ]
      then
      echo worker-2 FOUND
      cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
      a=`cat $IGNITIONDIR/$WORKERNAME-02.64`
      sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
      curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
      echo $i
  mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/worker-2.custom_property.xml
      fi

      grep $i $VMLIST|grep worker-3 > /dev/null 2>&1
      if [ $? = 0 ]
        then
        echo worker-3 FOUND
        cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
        a=`cat $IGNITIONDIR/$WORKERNAME-03.64`
        sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
        curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
        echo $i
    mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/worker-3.custom_property.xml
        fi
        grep $i $VMLIST|grep worker-4 > /dev/null 2>&1
        if [ $? = 0 ]
          then
          echo worker-4 FOUND
          cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
          a=`cat $IGNITIONDIR/$WORKERNAME-04.64`
          sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
          curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
          echo $i
      mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/worker-4.custom_property.xml
          fi
          grep $i $VMLIST|grep worker-5 > /dev/null 2>&1
          if [ $? = 0 ]
            then
            echo worker-5 FOUND
            cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
            a=`cat $IGNITIONDIR/$WORKERNAME-05.64`
            sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
            curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
            echo $i
        mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/worker-5.custom_property.xml
            fi

      grep $i $VMLIST|grep storage-0 > /dev/null 2>&1
      if [ $? = 0 ]
        then
        echo storage-0 FOUND
        cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
        a=`cat $IGNITIONDIR/$STORAGENAME-00.64`
        sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
        curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
        echo $i
    mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/storage-0.custom_property.xml
        fi

        grep $i $VMLIST|grep storage-1 > /dev/null 2>&1
        if [ $? = 0 ]
          then
          echo storage-1 FOUND
          cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
          a=`cat $IGNITIONDIR/$STORAGENAME-01.64`
          sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
          curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
          echo $i
      mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/storage-1.custom_property.xml

      grep $i $VMLIST|grep storage-2 > /dev/null 2>&1
      if [ $? = 0 ]
        then
        echo storage-2 FOUND
        cp $OPENSHIFT/custom_property.xml $IGNITIONDIR/custom_property.xml
        a=`cat $IGNITIONDIR/$STORAGENAME-02.64`
        sed -i "s/###DATA###/$a/" $IGNITIONDIR/custom_property.xml
        curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
        echo $i
    mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/storage-2.custom_property.xml
        fi
  grep $i $VMLIST|grep -i loadbalancer > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo loadbalancer FOUND
    cp $OPENSHIFT/LBDNS.xml $IGNITIONDIR/custom_property.xml
    sed -i "s/###MASTER0IP###/$MASTER0/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###MASTER1IP###/$MASTER1/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###MASTER2IP###/$MASTER2/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###WORKER0IP###/$WORKER0/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###WORKER1IP###/$WORKER1/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###WORKER2IP###/$WORKER2/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###MASTER0FQDN###/$MASTERNAME-00.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###MASTER1FQDN###/$MASTERNAME-01.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###MASTER2FQDN###/$MASTERNAME-02.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###WORKER0FQDN###/$WORKERNAME-00.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###WORKER1FQDN###/$WORKERNAME-01.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###WORKER2FQDN###/$WORKERNAME-02.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###STORAGE0FQDN###/$STORAGENAME-00.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###STORAGE1FQDN###/$STORAGENAME-01.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###STORAGE2FQDN###/$STORAGENAME-02.$DOMAIN/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###IPADDRESS###/$LB/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###NETMASK###/$NETMASK/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###DNS###/$PUBLICDNS/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###GATEWAY###/$GATEWAY/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###BOOTSTRAPIP###/$BOOTSTRAP/" $IGNITIONDIR/custom_property.xml
    KEY=`cat ssh_key.pub|base64 -w0`
    sed -i "s/###SSHKEY###/$KEY/" $IGNITIONDIR/custom_property.xml
    hostdata=`cat $IGNITIONDIR/NEEDED_DNS_ENTRIES|base64 -w0`
    srvdata=`cat $IGNITIONDIR/NEEDED_SRV_ENTRIES|base64 -w0`
    sed -i "s/###DNSDATA###/$hostdata/" $IGNITIONDIR/custom_property.xml
    sed -i "s/###SRVDATA###/$srvdata/" $IGNITIONDIR/custom_property.xml
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X PUT  $i/productSections -d "@$IGNITIONDIR/custom_property.xml"
mv $IGNITIONDIR/custom_property.xml $IGNITIONDIR/loadbalancer.custom_property.xml
  fi
done
