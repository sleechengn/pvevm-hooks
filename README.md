已经应用于 8.x、7.4、9.x

本项目适用于安装了NVIDIA官方驱动的的N卡，并适用安装了GNOME桌面的PVE系统，以及未安装GNOME桌面

使用效果：

虚拟机开机，GNOME桌面自动退出，开启虚拟机。虚拟机关机以后自动启动GNOME到桌面

1、（可选）可以安装GNOME

安装GNOME桌面方法

```
	apt update
	tasksel
	#然后选择桌面和GNOME
```
开启虚拟机前自动关闭GDM等桌面服务，并将显卡绑定在vfio模块以供虚拟机使用

适用于NVIDIA显卡，并安装了官方驱动

2、本项目安装

安装方法：

```
git clone https://github.com/sleechengn/pvevm-hooks
cd pvevm-hooks
chmod 755 install-hook.sh
./install-hook.sh <虚拟机编号>   
```

这样钩子设置完成，虚拟机启动、关闭、进程退出时就是执行这个脚本的内容

3、（可选）可以建建立桌面图标，然后用我提供的.sh脚本来启动

vm-start.sh

```
#!/usr/bin/bash

#VM ID
VMID=$1

#认证密码，此处改成你的密码
AUTH_PASSWORD="yourpassword"

#通过账号密码获取票据和凭证
auth_json=$(curl --silent --insecure --data "username=root@pam&password=$AUTH_PASSWORD"  https://localhost:8006/api2/json/access/ticket)
#提取JSON中的票据
ticket=$(echo $auth_json | jq --raw-output '.data.ticket')
#提取JSON中的凭证
csrf_token=$(echo $auth_json | jq --raw-output '.data.CSRFPreventionToken')

#用curl通过票据和凭证调用开机api
curl -k -v -X POST -b "PVEAuthCookie=$ticket" -H "CSRFPreventionToken: $csrf_token" https://localhost:8006/api2/json/nodes/pve/qemu/$VMID/status/start
```

启动方法

```
vm-start.sh xxxVMID
```
