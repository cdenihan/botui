#!/usr/bin/env bash

USER=pi
HOST="${RPI_HOST:-10.101.156.14}"
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
rsync -a --info=progress2 ./build/flutter-pi/pi3-64/ $USER@$HOST:/home/$USER/stp-velox
ssh $USER@$HOST "sudo systemctl restart flutter-ui.service"