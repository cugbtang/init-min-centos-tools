#!/bin/bash
# 安装单机k8s
## 前置环境
yum install socat conntrack ebtables ipset -y

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

sudo yum remove -y kubelet kubeadm kubectl
sudo yum install -y  kubectl

## kubeadmin style
is_admin(){

	echo
	echo "================================================================================"
	echo
	echo "deploy kubernetes with admin!"
	echo
	echo "install tools"
	echo
	sudo yum install -y  kubelet kubeadm kubectl
	systemctl enable kubelet && systemctl start kubelet

	echo "========================================================"
	echo "prepare images for kubernetes"
	echo
	images=(
	  kube-apiserver:v1.17.3
	  kube-proxy:v1.17.3
	  kube-controller-manager:v1.17.3
	  kube-scheduler:v1.17.3
	  coredns:1.6.5
	  etcd:3.4.3-0
	  pause:3.1
	)
	for imageName in ${images[@]} ; do
	    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
	done

	echo "========================================================"
	echo "init kubernetes"
	echo
	kubeadm init \
	--apiserver-advertise-address=192.168.142.144 \
	--image-repository registry.cn-hangzhou.aliyuncs.com/google_containers \
	--kubernetes-version v1.17.3 \
	--service-cidr=10.96.0.0/16 \
	--pod-network-cidr=10.244.0.0/16

	echo "========================================================"
	echo "copy kubeconfig for yourself"
	echo
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

	echo "========================================================"
	echo "deploy net plugin"
	echo
	kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

	echo "run command get the join command that worker node  can join this cluster"
	echo "kubeadm token create --print-join-command"
	echo
	echo 
	echo "if token exceed limit, you can create a token forever"
	echo "kubeadm token create --ttl 0 --print-join-command "
}

## kubekey
is_kk(){
	echo
	echo "================================================================================"
	echo
	echo "deploy kubernetes with kubekey!"
	echo "check deploy log with following command"
	echo `kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f`
	wget -q https://ghproxy.com/https://github.com/kubesphere/kubekey/releases/download/v2.0.0-rc.4/kubekey-v2.0.0-rc.4-linux-amd64.tar.gz | tar -zxvf
	export KKZONE=cn
	./kk create cluster --with-kubernetes v1.20.4 --with-kubesphere v3.1.1
}

while [ $# -gt 0 ]; do
	case "$1" in
		--kubeadmin)
			is_kubeadmin
			shift
			;;
		--kk)
			is_kk
			shift
			;;
		--*)
			echo "Illegal option $1"
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done
