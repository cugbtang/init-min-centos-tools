#!/bin/bash

root_user(){
	[ $UID -ne 0 ] && { echo “请使用root用户”;exit 1; }
}

# nfs
yum install -y nfs-utils

echo "/nfs/data/ *(insecure,rw,sync,no_root_squash)" > /etc/exports
mkdir -p /nfs/data
systemctl enable rpcbind
systemctl enable nfs-server
systemctl start rpcbind
systemctl start nfs-server
exportfs -r
exportfs
## =======================================================================
## 服务器端防火墙开放111、662、875、892、2049的 tcp / udp 允许，否则远端客户无法连接
## 客户端执行
## ServerIP = 1.1.1.1
## showmount -e 1.1.1.1((nfs service)
## mkdir /root/nfsmount
## mount -t nfs ${ServerIP}:/nfs/data/ /root/nfsmount
## =======================================================================

echo "===================================================================="
echo "add k8s provisioner"
NFS_SERVER=ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}'|head -n1
NFS_SERVER_DIR="/nfs/data"
sed -i 's#{NFS_SERVER}#'$NFS_SERVER'#g' ./nfs-provisioner.yaml
sed -i 's#{NFS_SERVER}#'$NFS_SERVER'#g' ./nfs-provisioner.yaml
