## Introduction
How to build an OpenShift Container Storage cluster with local VM Storage

[Documentation for installing OCS with Local VM Storage](https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.5/html-single/deploying_openshift_container_storage_on_vmware_vsphere/index#finding-available-storage-devices-vmware_local-storage)

- Install OCS Operator
- Install Local Storage Operator into the `local-storage` namespace
- label your 3 storage nodes as storage nodes     
  `oc label node <node name>  cluster.ocs.openshift.io/openshift-storage=`
- Display the nodes to make sure they are labeled properly

  `oc get nodes -l cluster.ocs.openshift.io/openshift-storage=`
```
NAME                                    STATUS   ROLES    AGE   VERSION
storage-00.stuocpvm1.stulipshires.com   Ready    worker   9h    v1.18.3+616db59
storage-01.stuocpvm1.stulipshires.com   Ready    worker   9h    v1.18.3+616db59
storage-02.stuocpvm1.stulipshires.com   Ready    worker   9h    v1.18.3+616db59
```
Collect the disk info from each node by applying Daemonset  
`oc apply -f https://raw.githubusercontent.com/dmoessne/ocs-disk-gather/master/ocs-disk-gatherer.yaml`

`kubectl logs --selector name=ocs-disk-gatherer --tail=-1 --since=10m --namespace default`

Cleaning up
Once you have collected the disk information you needed, you can remove everything like this:

`oc delete daemonsets ocs-disk-gatherer --namespace default`
