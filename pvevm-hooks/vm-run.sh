#!/bin/bash

VMID="$1"
SELECT="$2"

touch /tmp/$VMID-running
echo "VM $VMID is $SELECT" >> $(dirname $0)/$VMID-hooks.log

#cmd="nohup $(dirname $0)/vm-proc.sh $VMID > /dev/null 2>&1 &"
#echo "cmd=$cmd"
#sshpass -p @kernel32_ ssh -o StrictHostKeyChecking=no root@localhost $cmd
#nohup $(dirname $0)/vm-proc.sh $VMID > /dev/null 2>&1 &

cmd="$(dirname $0)/vm-proc.sh $VMID > /dev/null &"
echo $cmd >> /tmp/cmd.fifo

echo "run monitor for proc exit"
