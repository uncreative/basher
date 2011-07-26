#!/bin/sh


#necessary because ~ in quotes becomes messed up..
if [ "$(whoami)" != 'root' ]; then
    home_dir=~; 
else
    home_dir=~root; 
fi

KEY="${home_dir}/.ssh/id_dsa.pub"

if [ ! -f ${home_dir}/.ssh/id_dsa.pub ];then
    echo "private key not found at $KEY"
    echo "* please create it with "ssh-keygen -t dsa" *"
    echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
    exit
fi

if [ -z $1 ];then
    echo "Please specify user@host.tld as the first switch to this script"
    exit
fi

echo "Putting ${KEY} on $*... "

KEYCODE=$(<"$KEY")
echo "got keycode: ${KEYCODE}"
ssh -q $* "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; echo "$KEYCODE" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"

echo "done!"