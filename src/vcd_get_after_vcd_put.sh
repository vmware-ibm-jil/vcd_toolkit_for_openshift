. ./env.sh
echo $OSENVID
VMLIST=vmlist
VMLIST1=vmlist1
auth=`curl -i -k -H "Accept:application/*+xml;version=31.0" -u $VCDUSR@$VCDORG:$VCDPASS -X POST https://$VCDIP/api/sessions|grep x-vcloud-authorization|awk '{print $2}'|sed -e "s/\r//"`

echo "#####$auth#####"

for i in `cat $VMLIST1` 
  do
  grep $i $VMLIST|grep bootstrap > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo bootstrap FOUND
    echo $i
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections  > /tmp/bootstrap
    fi

  grep $i $VMLIST|grep master-0 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo master-0 FOUND
    echo $i
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections > /tmp/master0
    fi

  grep $i $VMLIST|grep master-1 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo master-1 FOUND
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections  > /tmp/master1
    fi

  grep $i $VMLIST|grep master-2 > /dev/null 2>&1
  if [ $? = 0 ]
    then
     echo master-2 FOUND
     curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections > /tmp/master2
     echo $i
  fi

  grep $i $VMLIST|grep worker-0 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo worker-0 FOUND
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections > /tmp/worker0
    echo $i
    fi

  grep $i $VMLIST|grep worker-1 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo worker-1 FOUND
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections > /tmp/worker1
    echo $i
    fi

  grep $i $VMLIST|grep worker-2 > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo worker-2 FOUND
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections > /tmp/worker2
    echo $i
    fi

  grep $i $VMLIST|grep loadbalancer > /dev/null 2>&1
  if [ $? = 0 ]
    then
    echo loadbalancer FOUND
    curl -i -k -H "Accept: application/*+xml;version=31.0" -H "x-vcloud-authorization: $auth" -H "Content-Type: application/vnd.vmware.vcloud.productSections+xml" -X GET  $i/productSections > /tmp/loadb
  fi
done

