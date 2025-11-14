#!/usr/bin/env bash

# https://gist.github.com/planetceres/917840478e1e4d45f8373667630e51a0
# http://billauer.co.il/blog/2013/02/usb-reset-ehci-uhci-linux/
if [[ $EUID != 0 ]] ; then
  echo This must be run as root!
  exit 1
fi

for xhci in /sys/bus/pci/drivers/?hci_hcd ; do

  if ! cd $xhci ; then
    echo Weird error. Failed to change directory to $xhci
    exit 1
  fi

  echo Resetting devices from $xhci...

  for i in ????:??:??.? ; do
    echo -n "$i" > unbind
    echo -n "$i" > bind
  done
done

