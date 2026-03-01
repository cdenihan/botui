#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RPI_HOST="${RPI_HOST:-192.168.68.110}"
RPI_USER="${RPI_USER:-pi}"
REMOTE_APP_DIR="/home/${RPI_USER}/stp-velox"
SERVICE_NAME="flutter-ui"

# Support both repo (build output) and release bundle (files at root) layouts
if [ -d "${SCRIPT_DIR}/build/flutter-pi/pi3-64" ]; then
  BUILD_DIR="${SCRIPT_DIR}/build/flutter-pi/pi3-64"
else
  BUILD_DIR="${SCRIPT_DIR}"
fi
SERVICE_FILE="${SCRIPT_DIR}/systemd/flutter-ui.service"

# --- Preflight checks ---
if [ ! -f "${BUILD_DIR}/app.so" ]; then
  echo "ERROR: No Flutter build found in ${BUILD_DIR}"
  echo "Run build.sh first, or extract a release bundle."
  exit 1
fi

if [ ! -f "$SERVICE_FILE" ]; then
  echo "ERROR: Systemd service file not found: ${SERVICE_FILE}"
  exit 1
fi

# --- Test SSH connectivity ---
echo "Testing SSH connection to ${RPI_USER}@${RPI_HOST}..."
if ! ssh -o ConnectTimeout=5 "${RPI_USER}@${RPI_HOST}" "echo ok" > /dev/null 2>&1; then
  echo "ERROR: Cannot connect to ${RPI_USER}@${RPI_HOST}"
  exit 1
fi

# --- Stop service ---
echo "Stopping ${SERVICE_NAME} service..."
ssh "${RPI_USER}@${RPI_HOST}" "sudo systemctl stop ${SERVICE_NAME} || true"

# --- Upload build ---
echo "Uploading build to ${RPI_HOST}:${REMOTE_APP_DIR}..."
rsync -a --info=progress2 "${BUILD_DIR}/" "${RPI_USER}@${RPI_HOST}:${REMOTE_APP_DIR}"

# --- Install systemd unit ---
echo "Installing systemd service..."
rsync -a "${SERVICE_FILE}" "${RPI_USER}@${RPI_HOST}:/home/${RPI_USER}/flutter-ui.service"
ssh "${RPI_USER}@${RPI_HOST}" "
  sudo mv /home/${RPI_USER}/flutter-ui.service /etc/systemd/system/flutter-ui.service &&
  sudo systemctl daemon-reload
"

# --- Enable & start service ---
echo "Enabling and starting ${SERVICE_NAME}..."
ssh "${RPI_USER}@${RPI_HOST}" "
  sudo systemctl enable ${SERVICE_NAME}
  sudo systemctl start ${SERVICE_NAME}
"

echo "Deploy complete."
