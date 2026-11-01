#!/usr/bin/env bash

DIR=/srv/app
MANIFEST=/root/app.sha256

[[ $EUID -eq 0 ]] || { echo "Executeu-lo amb sudo."; exit 1; }
mountpoint -q "$DIR" || { echo "$DIR no és un punt de muntatge: munteu-hi primer el LV."; exit 1; }

mkdir -p "$DIR/data"
for i in $(seq -w 1 300); do
  # fitxers de 4 KiB a 256 KiB, contingut aleatori
  head -c $(( (RANDOM % 64 + 1) * 4096 )) /dev/urandom > "$DIR/data/fitxer-$i.bin"
done
printf 'port=8080\nmode=produccio\n' > "$DIR/data/config.ini"

( cd "$DIR" && find data -type f -print0 | sort -z | xargs -0 sha256sum ) > "$MANIFEST"

cat > /usr/local/bin/verifica-app <<VERIF
#!/bin/sh
# Compara les dades de $DIR amb el manifest. Només mostra els fitxers que no coincideixen.
cd $DIR && sha256sum -c --quiet $MANIFEST && echo "OK: totes les dades de l'aplicació intactes"
VERIF
chmod 755 /usr/local/bin/verifica-app

echo "Creats $(wc -l < "$MANIFEST") fitxers ($(du -sh "$DIR/data" | cut -f1)) i el manifest $MANIFEST."
echo "Verificació en qualsevol moment: sudo verifica-app"
