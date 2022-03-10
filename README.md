# init-min-centos7

zsh+ohmyzsh, kk, kubectl, k9s, 
##

## setup kubernetes
```sh
wget -qO https://raw.github.com/cugbtang/init-min-centos-tools/master/k8s-setup.sh | sh --kk
国内：
wget -qO https://ghproxy.com/https://raw.github.com/cugbtang/init-min-centos-tools/master/k8s-setup.sh | sh --kk

```

## nfs-provisioner in kubernetes
```sh
wget -qO https://raw.github.com/cugbtang/init-min-centos-tools/master/nfs-provisioner.yaml
国内：
wget -qO https://ghproxy.com/https://raw.github.com/cugbtang/init-min-centos-tools/master/nfs-provisioner.yaml

NFS_SERVER=ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}'|head -n1
NFS_SERVER_DIR="/nfs/data"
sed -i 's#{NFS_SERVER}#'$NFS_SERVER'#g' ./nfs-provisioner.yaml
sed -i 's#{NFS_SERVER}#'$NFS_SERVER'#g' ./nfs-provisioner.yaml
```
