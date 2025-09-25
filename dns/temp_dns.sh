#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "Please run with 'sudo', exiting."
  exit
fi

mount -o ro --bind ./resolv.conf /etc/resolv.conf
echo "Temporary /etc/resolv.conf in place."

systemctl restart NetworkManager.service
echo "Restarted NetworkManager."
echo
echo "Press any key to restore /etc/resolv.conf ..."

read -s -n 1

umount -f /etc/resolv.conf
echo
echo "Original /etc/resolv.conf restored."

systemctl restart NetworkManager.service
echo "Restarted NetworkManager."
