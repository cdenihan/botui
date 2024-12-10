USER=pi
HOST=192.168.68.3
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
rsync -a --info=progress2 ./build/flutter_assets/ $USER@$HOST:/home/$USER/stp-velox
