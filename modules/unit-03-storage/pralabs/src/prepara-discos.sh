#!/usr/bin/env bash

command -v qemu-img >/dev/null || { echo "No trobo qemu-img: instal·leu QEMU."; exit 1; }

discs=(b c); [[ ${1:-} == --disc-d ]] && discs=(d)

for n in "${discs[@]}"; do
  f="lvm-$n.qcow2"
  if [[ -e $f ]]; then
    echo "Ja existeix $f: no el toco."
  else
    qemu-img create -f qcow2 "$f" 10G >/dev/null
    echo "Creat $f (10 GiB, creix a mesura que s'hi escriu)."
  fi
done

echo
echo "Afegiu a l'ordre qemu-system-x86_64 del vostre run.sh (abans de l'última línia):"
for n in "${discs[@]}"; do
  echo "  -drive file=lvm-$n.qcow2,if=virtio,format=qcow2,serial=lvm-$n,detect-zeroes=on \\"
done
echo
echo "detect-zeroes=on fa que QEMU no ocupi espai a l'amfitrió quan la VM escriu zeros"
