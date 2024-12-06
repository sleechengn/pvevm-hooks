#!/bin/bash

VMID="$1"
SELECT="$2"

echo "VM $VMID is exiting" >> $(dirname $0)/$VMID-hooks.log

v_no=$(lspci -nn -D|grep NVIDIA|grep VGA|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $1}')
v_id=$(lspci -nn -D|grep NVIDIA|grep VGA|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $3}')
v_id="$(echo $v_id|cut -c 1-4) $(echo $v_id|cut -c 6-9)"
v_dv="nvidia"

a_no=$(lspci -nn -D|grep NVIDIA|grep Audio|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $1}')
a_id=$(lspci -nn -D|grep NVIDIA|grep Audio|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $3}')
a_id="$(echo $a_id|cut -c 1-4) $(echo $a_id|cut -c 6-9)"
a_dv="snd_hda_intel"

#u_no=$(lspci -nn -D|grep USB|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $1}')
#u_id=$(lspci -nn -D|grep USB|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $3}')
#u_id="$(echo $u_id|cut -c 1-4) $(echo $u_id|cut -c 6-9)"
#u_dv="xhci_hcd"

echo "unbind $v_no from vfio-pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
echo $v_no > /sys/bus/pci/drivers/vfio-pci/unbind

echo "remove $v_id from vfio-pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
echo $v_id > /sys/bus/pci/drivers/vfio-pci/remove_id

echo "unbind $a_no from vfio-pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
echo $a_no > /sys/bus/pci/drivers/vfio-pci/unbind

echo "remove $a_id from vfio-pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
echo $a_id > /sys/bus/pci/drivers/vfio-pci/remove_id

#echo "unbind $u_no from vfio-pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
#echo $u_no > /sys/bus/pci/drivers/vfio-pci/unbind

#echo "remove $u_id from vfio-pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
#echo $u_id > /sys/bus/pci/drivers/vfio-pci/remove_id

#echo "reset $v_no from pci "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
#echo 1 > /sys/bus/pci/devices/$v_no/reset

echo "load mod nvidia "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
modprobe nvidia

echo "bind $v_no to $v_dv "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
echo $v_no > /sys/bus/pci/drivers/$v_dv/bind

echo "bind $a_no to $a_dv "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
echo $a_no > /sys/bus/pci/drivers/$a_dv/bind

#echo "bind $u_no to $u_dv "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
#echo $u_no >/sys/bus/pci/drivers/$u_dv/bind

echo "start nvidia-persistenced "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
/usr/bin/nvidia-persistenced --user nvpd

echo "load mod nvidia-drm set modeset 1 "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
modprobe nvidia-drm modeset=1

echo "vfio-teardown start "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
$(dirname $0)/vfio-teardown.sh

#modprobe btusb
#hciconfig hci0 up

#hciconfig hci0 up
#systemctl start bluetooth
echo "VM $VMID stopped "$(date "+%Y-%m-%d %H:%M:%S") >> $(dirname $0)/$VMID-hooks.log
