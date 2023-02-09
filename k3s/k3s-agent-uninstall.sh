#!/bin/sh
set -x
[ $(id -u) -eq 0 ] || exec sudo $0 $@

/usr/local/bin/k3s-killall.sh

if command -v systemctl; then
    systemctl disable k3s-node
    systemctl reset-failed k3s-node
    systemctl daemon-reload
fi
if command -v rc-update; then
    rc-update delete k3s-node default
fi

rm -f /etc/systemd/system/k3s-node.service
rm -f /etc/systemd/system/k3s-node.service.env

remove_uninstall() {
    rm -f /usr/local/bin/k3s-node-uninstall.sh
}
trap remove_uninstall EXIT

if (ls /etc/systemd/system/k3s*.service || ls /etc/init.d/k3s*) >/dev/null 2>&1; then
    set +x; echo 'Additional k3s services installed, skipping uninstall of k3s'; set -x
    exit
fi

for cmd in kubectl crictl ctr; do
    if [ -L /usr/local/bin/$cmd ]; then
        rm -f /usr/local/bin/$cmd
    fi
done

rm -rf /etc/rancher/k3s
rm -rf /run/k3s
rm -rf /run/flannel
rm -rf /var/lib/rancher/k3s
rm -rf /var/lib/kubelet
rm -f /usr/local/bin/k3s
rm -f /usr/local/bin/k3s-killall.sh
