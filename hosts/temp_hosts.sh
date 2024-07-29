#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "Please run with 'sudo', exiting."
  exit
fi

mount --bind ./hosts /etc/hosts
echo "Temporary /etc/hosts in place."
echo
echo "Press any key to restore /etc/hosts ..."

read -s -n 1

umount -f /etc/hosts
echo
echo "Original /etc/hosts restored."
