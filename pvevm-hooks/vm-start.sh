#!/bin/bash

VMID="$1"
SELECT="$2"

echo "VM $VMID is $SELECT " > $(dirname $0)/$VMID-hooks.log

v_no=$(lspci -nn -D|grep NVIDIA|grep VGA|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $1}')
v_id=$(lspci -nn -D|grep NVIDIA|grep VGA|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $3}')
v_id="$(echo $v_id|cut -c 1-4) $(echo $v_id|cut -c 6-9)"
v_dv=$(lspci -k -s $v_no|grep "Kernel driver in use"|awk '{print $5}')

a_no=$(lspci -nn -D|grep NVIDIA|grep Audio|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $1}')
a_id=$(lspci -nn -D|grep NVIDIA|grep Audio|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $3}')
a_id="$(echo $a_id|cut -c 1-4) $(echo $a_id|cut -c 6-9)"
a_dv=$(lspci -k -s $a_no|grep "Kernel driver in use"|awk '{print $5}')

#u_no=$(lspci -nn -D|grep USB|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $1}')
#u_id=$(lspci -nn -D|grep USB|awk '{print $1}'|xargs -i lspci -s {} -n -D|awk '{print $3}')
#u_id="$(echo $u_id|cut -c 1-4) $(echo $u_id|cut -c 6-9)"
#u_dv=$(lspci -k -s $u_no|grep "Kernel driver in use"|awk '{print $5}')

#echo $v_no
#echo $v_id
#echo $v_dv

#echo $a_no
#echo $a_id
#echo $a_dv

#echo $u_no
#echo $u_id
#echo $u_dv

echo "VM $VMID is starting prepare invoke vfio-startup.sh" >> $(dirname $0)/$VMID-hooks.log

$(dirname $0)/vfio-startup.sh
#systemctl stop bluetooth
#hciconfig hci0 down

echo "kill all /dev/nvidia usage" >> $(dirname $0)/$VMID-hooks.log
lsof /dev/nvidia*|grep -v grep|grep -v PID|awk '{print $2}'|uniq|xargs kill -9 >> $(dirname $0)/$VMID-hooks.log 2>&1

#nvidia_drm             65536  0
#nvidia_modeset       1200128  1 nvidia_drm
#nvidia              35495936  1 nvidia_modeset
#drm_kms_helper        311296  1 nvidia_drm
#drm                   614400  4 drm_kms_helper,nvidia,nvidia_drm

#echo "ready to remove mode drm" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r drm

#echo "ready to remove mode drm_kms_helper" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r drm_kms_helper

#echo "ready to remove mod nvidia_modeset" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r nvidia-modeset
#rcode=$?
#echo "remove mod nvidia_modeset ret code:$rcode" >> $(dirname $0)/$VMID-hooks.log

echo "ready to remove mod nvidia_drm" >> $(dirname $0)/$VMID-hooks.log
modprobe -r nvidia-drm >> $(dirname $0)/$VMID-hooks.log 2>&1
rcode=$?
echo "remove mod nvidia_drm ret code:$rcode" >> $(dirname $0)/$VMID-hooks.log

while [ $rcode != 0 ]
do
  echo "nvidia_drm remove code: $rcode error 1 second retry"
  sleep 1
  modprobe -r nvidia-drm >> $(dirname $0)/$VMID-hooks.log 2>&1
  rcode=$?
done

#echo "ready to remove mod nvidia_modeset_2" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r nvidia-modeset
#rcode=$?
#echo "remove mod nvidia_modeset_2 ret code:$rcode" >> $(dirname $0)/$VMID-hooks.log

#echo "ready to remove mod nvidia_drm_2" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r nvidia-drm
#rcode=$?
#echo "remove mod nvidia_drm_2 ret code:$rcode" >> $(dirname $0)/$VMID-hooks.log

#echo "ready to remove mode nvidia" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r nvidia

#echo "ready to remove mode nvidia_modeset" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r nvidia-modeset

#echo "ready to remove mod nvidia_drm" >> $(dirname $0)/$VMID-hooks.log
#modprobe -r nvidia-drm

echo "ready to unbind $v_no to $v_dv" >> $(dirname $0)/$VMID-hooks.log
echo $v_no > /sys/bus/pci/drivers/$v_dv/unbind
if ! lsmod | grep "vfio_pci" &> /dev/null ; then
    modprobe vfio-pci
fi

echo "ready to remove mode nvidia" >> $(dirname $0)/$VMID-hooks.log
modprobe -r nvidia >> $(dirname $0)/$VMID-hooks.log 2>&1

echo "ready to bind $v_no to vfio" >> $(dirname $0)/$VMID-hooks.log
echo $v_id > /sys/bus/pci/drivers/vfio-pci/new_id

echo $a_no > /sys/bus/pci/drivers/$a_dv/unbind
if ! lsmod | grep "vfio_pci" &> /dev/null ; then
    modprobe vfio-pci
fi
echo $a_id > /sys/bus/pci/drivers/vfio-pci/new_id

#hciconfig hci0 down
#modprobe -r btusb


#echo $u_no > /sys/bus/pci/drivers/$u_dv/unbind
#if ! lsmod | grep "vfio_pci" &> /dev/null ; then
#    modprobe vfio-pci
#fi
#echo $u_id > /sys/bus/pci/drivers/vfio-pci/new_id
#touch /tmp/$VMID-running
