#!/usr/bin/env bash
set -e

USER=pi
HOST="${RPI_HOST:-192.168.68.110}"
NO_RESTART=false

for arg in "$@"; do
  case $arg in
    --no-restart)
      NO_RESTART=true
      shift
      ;;
  esac
done

flutterpi_tool build --arch=arm64 --cpu=pi3 --release

rsync -a --info=progress2 ./build/flutter-pi/pi3-64/ \
  $USER@$HOST:/home/$USER/stp-velox

if [ "$NO_RESTART" = false ]; then
  ssh $USER@$HOST "sudo systemctl restart flutter-ui"
else
  echo "Skipping service restart (--no-restart)"
fi
