已经应用于	8.2、7.4	开启虚拟机前自动关闭GDM等桌面服务，并将显卡绑定在vfio模块以供虚拟机使用

适用于NVIDIA显卡

安装方法：

1、解压后目录都在 /opt 下
2、/opt/fifo下的 cmd.sh cmd1.sh cmd2.sh 都添加开启在rc.local自动启动
	开启rc.local启动方法
		使用  systemctl enable rc-local 命令启动rc.local启动
		新建	 /etc/rc.local 写入启动  cmd.sh cmd1.sh cmd2.sh 脚本，注意跟&符号非阻塞执行
		chmod +x /etc/rc.local 赋于执行权限
		重启电脑
3、直通显卡，并设置hook
		hookscript: local:snippets/vm-hook.sh