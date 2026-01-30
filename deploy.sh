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
dart pub get

drat run build_runner build -d

# Build Flutter app
flutterpi_tool build --arch=arm64 --cpu=pi3 --release

# Copy Flutter build
rsync -a --info=progress2 ./build/flutter-pi/pi3-64/ \
  $USER@$HOST:/home/$USER/stp-velox

# Copy systemd service file
rsync -a ./systemd/flutter-ui.service \
  $USER@$HOST:/home/$USER/flutter-ui.service

# Move service file + reload systemd
ssh $USER@$HOST "
  sudo mv /home/$USER/flutter-ui.service /etc/systemd/system/flutter-ui.service &&
  sudo systemctl daemon-reload
  sudo systemctl enable flutter-ui.service
"

if [ "$NO_RESTART" = false ]; then
  ssh $USER@$HOST "sudo systemctl restart flutter-ui"
else
  echo "Skipping service restart (--no-restart)"
fi
