# Windows PowerShell script equivalent

# User and host configuration
$user = "pi"
$hostAddr = $env:RPI_HOST
if (-not $hostAddr) { $hostAddr = "10.101.156.14" }

# Build the Flutter project for Raspberry Pi
flutterpi_tool build --arch=arm64 --cpu=pi3 --release

# Define source and destination paths
$source = ".\build\flutter-pi\pi3-64\"
$destination = "$user@${hostAddr}:/home/$user/stp-velox"

# Copy files to Raspberry Pi
# Option 1: Using scp (requires OpenSSH)
# scp -r $source $destination

# Option 2: Using rsync via WSL (if installed)
wsl rsync -a --info=progress2 /mnt/c/path/to/build/flutter-pi/pi3-64/ $user@${hostAddr}:/home/$user/stp-velox

# Restart the service on Raspberry Pi
ssh $user@$hostAddr "sudo systemctl restart flutter-ui.service"
